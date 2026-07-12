//
//  TipPurchaseController.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class TipPurchaseController: ObservableObject {

    private enum Constants {

        static let indicatorDisplayNanoseconds: UInt64 = 8_000_000_000
    }

    @Published private(set) var isPurchasing = false
    @Published var isSuccessIndicatorVisible = false
    @Published var isErrorAlertVisible = false

    private var indicatorTask: Task<Void, Never>?

    func purchase() {
        guard !isPurchasing else {
            return
        }

        isPurchasing = true

        Task { [weak self] in
            guard let self else {
                return
            }

            defer {
                isPurchasing = false
            }

            do {
                let result = try await PurchaseManager.shared.purchaseConsumable(
                    productIdentifier: StoreProductIdentifiers.tips
                )

                guard result == .purchased else {
                    return
                }

                showSuccessIndicator()
            } catch {
                isErrorAlertVisible = true
            }
        }
    }

    private func showSuccessIndicator() {
        indicatorTask?.cancel()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isSuccessIndicatorVisible = true
        }

        indicatorTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Constants.indicatorDisplayNanoseconds)

            guard !Task.isCancelled, let self else {
                return
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.isSuccessIndicatorVisible = false
            }
        }
    }
}
