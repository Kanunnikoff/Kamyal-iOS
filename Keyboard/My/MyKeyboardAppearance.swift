//
//  MyKeyboardAppearance.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import SwiftUI
import KeyboardKit

class MyKeyboardAppearance: StandardKeyboardAppearance {
    
    @AppStorage("SettingsView.Keyboard.isKeyboardLatin", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardLatin: Bool = false
    
    @AppStorage("SettingsView.Keyboard.isKeyboardIngush", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardIngush: Bool = false
    
    // Стиль "всплывашки" при нажатии и удержании на кнопку (с показом похожих букв иных алфавитов)
    override func actionCalloutStyle() -> ActionCalloutStyle {
        var style = super.actionCalloutStyle()
//         style.callout.backgroundColor = .red
        return style
    }
    
    override func buttonImage(for action: KeyboardAction) -> Image? {
        super.buttonImage(for: action)
    }
    
    override func buttonStyle(
        for action: KeyboardAction,
        isPressed: Bool
    ) -> KeyboardButtonStyle {
            var style = super.buttonStyle(for: action, isPressed: isPressed)
//             style.cornerRadius = 10
//        style.font = Config.customFont
            return style
        }
    
    override func buttonText(for action: KeyboardAction) -> String? {
        switch action {
            case .space:
                if isKeyboardLatin {
                    return "Juqh"
                } else {
                    if isKeyboardIngush {
                        return "Юкъ"
                    } else {
                        return "Пробел"
                    }
                }
            case .return:
                if isKeyboardLatin {
                    return "Čujazdar"
                } else {
                    if isKeyboardIngush {
                        return "Чуяздар"
                    } else {
                        return "Ввод"
                    }
                }
            default:
                return super.buttonText(for: action)
        }
    }
    
    // Стиль "всплывашки" при нажатии на кнопку
    override func inputCalloutStyle() -> InputCalloutStyle {
        var style = super.inputCalloutStyle()
        // style.callout.backgroundColor = .red
        return style
    }
}
