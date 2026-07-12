//
//  MyKeyboardAppearance.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

enum MyKeyboardAppearance {

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
