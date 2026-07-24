//
//  ShopViewModifier.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import SwiftUI

/// Запускает обработку новых и незавершённых покупок вместе с представлением.
struct ShopViewModifier: ViewModifier {

    /// Подключает наблюдение StoreKit на время существования содержимого.
    ///
    /// - Parameter content: Исходное содержимое представления.
    func body(content: Content) -> some View {
        content
            .task {
                await PurchaseManager.shared.startObservingTransactions()
                await PurchaseManager.shared.processUnfinishedTransactions()
            }
    }
}

extension View {

    /// Подключает обработку покупок StoreKit к представлению.
    ///
    /// - Returns: Представление, запускающее наблюдение за транзакциями.
    func shop() -> some View {
        modifier(ShopViewModifier())
    }
}
