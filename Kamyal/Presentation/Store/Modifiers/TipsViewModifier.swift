//
//  TipsViewModifier.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import SwiftUI

/// Показывает состояние успешной покупки чаевых или сообщение об ошибке.
struct TipsViewModifier: ViewModifier {

    @ObservedObject var purchaseController: TipPurchaseController

    /// Накладывает индикатор благодарности и предупреждение об ошибке.
    ///
    /// - Parameter content: Исходное содержимое представления.
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if purchaseController.isSuccessIndicatorVisible {
                    DoneIndicatorView(
                        message: "Большое спасибо за поддержку!",
                        startImageName: "dollarsign",
                        endImageName: "heart.fill"
                    )
                }
            }
            .alert(
                "Ошибка",
                isPresented: $purchaseController.isErrorAlertVisible,
                actions: {
                    Button("ОК", role: .cancel) {
                    }
                },
                message: {
                    Text("Я очень ценю Ваше желание поддержать проект, но покупку не удалось завершить. Пожалуйста, повторите попытку позже.")
                }
            )
    }
}

extension View {

    /// Подключает отображение результата покупки чаевых.
    ///
    /// - Parameter purchaseController: Контроллер, публикующий состояние покупки.
    /// - Returns: Представление с индикатором успеха и предупреждением об ошибке.
    func tips(purchaseController: TipPurchaseController) -> some View {
        modifier(TipsViewModifier(purchaseController: purchaseController))
    }
}
