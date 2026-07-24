//
//  MyKeyboardAppearance.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

/// Выбирает локализованные подписи служебных клавиш.
enum MyKeyboardAppearance {

    /// Возвращает подпись пробела или клавиши ввода для выбранного алфавита.
    ///
    /// - Parameters:
    ///   - action: Действие настраиваемой клавиши.
    ///   - isKeyboardLatin: Признак латинской раскладки.
    ///   - isKeyboardIngush: Признак ингушских подписей интерфейса.
    /// - Returns: Пользовательская подпись либо `nil` для стандартного содержимого.
    static func buttonTitle(
        for action: KeyboardAction,
        isKeyboardLatin: Bool,
        isKeyboardIngush: Bool
    ) -> String? {
        switch action {
        case .space:
            if isKeyboardLatin { return "Juqh" }
            return isKeyboardIngush ? "Юкъ" : "Пробел"

        case .primary:
            if isKeyboardLatin { return "Čujazdar" }
            return isKeyboardIngush ? "Чуяздар" : "Ввод"

        default:
            return nil
        }
    }
}
