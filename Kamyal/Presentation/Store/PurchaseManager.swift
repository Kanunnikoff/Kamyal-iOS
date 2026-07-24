//
//  PurchaseManager.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import FirebaseAnalytics
import Foundation
import OSLog
import StoreKit

/// Результат попытки купить расходуемый товар.
enum ConsumablePurchaseResult: Equatable {

    case purchased
    case pending
    case cancelled
}

/// Ошибки подготовки и проверки покупки.
enum PurchaseManagerError: LocalizedError {

    case productNotFound
    case unverifiedTransaction
    case unknownPurchaseResult

    var errorDescription: String? {
        switch self {
            case .productNotFound:
                return "Товар временно недоступен. Повторите попытку позже."

            case .unverifiedTransaction:
                return "Не удалось проверить покупку."

            case .unknownPurchaseResult:
                return "Не удалось определить результат покупки."
        }
    }
}

/// Последовательно обрабатывает покупки StoreKit и передаёт проверенные транзакции в аналитику.
actor PurchaseManager {

    static let shared = PurchaseManager()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? Util.getAppDisplayName(),
        category: "PurchaseManager"
    )

    private var transactionUpdatesTask: Task<Void, Never>?
    private var purchaseIntentsTask: Task<Void, Never>?
    private var loggedTransactionIdentifiers: Set<UInt64> = []

    /// Создаёт единственный экземпляр обработчика покупок.
    private init() {
    }

    /// Запускает наблюдение за обновлениями транзакций и намерениями покупок.
    ///
    /// Повторный вызов не создаёт дополнительные задачи наблюдения.
    func startObservingTransactions() {
        guard transactionUpdatesTask == nil else {
            return
        }

        transactionUpdatesTask = Task { [weak self] in
            for await verificationResult in Transaction.updates {
                guard let self else {
                    return
                }

                await self.process(verificationResult: verificationResult)
            }
        }

        if #available(iOS 16.4, *) {
            purchaseIntentsTask = Task { [weak self] in
                for await purchaseIntent in PurchaseIntent.intents {
                    guard let self else {
                        return
                    }

                    await self.process(purchaseIntent: purchaseIntent)
                }
            }
        }
    }

    /// Обрабатывает проверяемые транзакции, оставшиеся незавершёнными.
    func processUnfinishedTransactions() async {
        for await verificationResult in Transaction.unfinished {
            await process(verificationResult: verificationResult)
        }
    }

    /// Покупает расходуемый товар с указанным идентификатором.
    ///
    /// - Parameter productIdentifier: Идентификатор товара в App Store Connect.
    /// - Returns: Состояние завершения попытки покупки.
    /// - Throws: Ошибку загрузки товара, покупки или проверки транзакции.
    func purchaseConsumable(productIdentifier: String) async throws -> ConsumablePurchaseResult {
        guard let product = try await Product.products(for: [productIdentifier]).first else {
            throw PurchaseManagerError.productNotFound
        }

        return try await process(purchaseResult: product.purchase())
    }

    /// Обрабатывает покупку, начатую системой вне текущего экрана приложения.
    ///
    /// - Parameter purchaseIntent: Намерение покупки, полученное от StoreKit.
    @available(iOS 16.4, *)
    private func process(purchaseIntent: PurchaseIntent) async {
        do {
            _ = try await process(purchaseResult: purchaseIntent.product.purchase())
        } catch {
            logger.error("Не удалось обработать намерение покупки: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Проверяет результат покупки, завершает успешную транзакцию и возвращает её состояние.
    ///
    /// - Parameter purchaseResult: Результат, полученный от StoreKit.
    /// - Returns: Состояние расходуемой покупки.
    /// - Throws: Ошибку проверки или неизвестный вариант результата.
    private func process(
        purchaseResult: Product.PurchaseResult
    ) async throws -> ConsumablePurchaseResult {
        switch purchaseResult {
            case .success(let verificationResult):
                let transaction = try verifiedTransaction(from: verificationResult)

                logTransactionIfNeeded(transaction)

                // Чаевые не открывают содержимое, поэтому после проверки
                // транзакцию можно завершить сразу и не оставлять в очереди StoreKit.
                await transaction.finish()

                return .purchased

            case .pending:
                return .pending

            case .userCancelled:
                return .cancelled

            @unknown default:
                throw PurchaseManagerError.unknownPurchaseResult
        }
    }

    /// Проверяет и завершает транзакцию из последовательности обновлений.
    ///
    /// - Parameter verificationResult: Результат проверки, предоставленный StoreKit.
    private func process(
        verificationResult: VerificationResult<Transaction>
    ) async {
        do {
            let transaction = try verifiedTransaction(from: verificationResult)

            logTransactionIfNeeded(transaction)

            // Обновление может прийти после одобрения покупки или с другого
            // устройства. Завершаем только проверенную транзакцию.
            await transaction.finish()
        } catch {
            logger.error("StoreKit передал неподтверждённую транзакцию: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Извлекает подтверждённую транзакцию из результата проверки.
    ///
    /// - Parameter verificationResult: Проверяемая транзакция StoreKit.
    /// - Returns: Транзакция с действительной подписью.
    /// - Throws: `PurchaseManagerError.unverifiedTransaction`, если проверка не пройдена.
    private func verifiedTransaction(
        from verificationResult: VerificationResult<Transaction>
    ) throws -> Transaction {
        switch verificationResult {
            case .verified(let transaction):
                return transaction

            case .unverified:
                throw PurchaseManagerError.unverifiedTransaction
        }
    }

    /// Один раз за запуск передаёт действующую транзакцию в Firebase Analytics.
    ///
    /// - Parameter transaction: Проверенная транзакция для регистрации.
    private func logTransactionIfNeeded(_ transaction: Transaction) {
        guard transaction.revocationDate == nil,
              transaction.revocationReason == nil,
              loggedTransactionIdentifiers.insert(transaction.id).inserted else {
            return
        }

        // Одна покупка может одновременно вернуться из product.purchase()
        // и появиться в Transaction.updates. Передаём только проверенную
        // транзакцию и не создаём повторное событие в рамках текущего запуска.
        Analytics.logTransaction(transaction)
    }
}
