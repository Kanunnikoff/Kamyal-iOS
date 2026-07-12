//
//  ShopViewModifier.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import SwiftUI

struct ShopViewModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .task {
                await PurchaseManager.shared.startObservingTransactions()
                await PurchaseManager.shared.processUnfinishedTransactions()
            }
    }
}

extension View {

    func shop() -> some View {
        modifier(ShopViewModifier())
    }
}
