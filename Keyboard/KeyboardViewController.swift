//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

class KeyboardViewController: KeyboardInputViewController {

    override func viewWillSetupKeyboardKit() {
        setupKeyboardKit(for: .kamyal) { [weak self] result in
            guard let self else { return }

            // Пользовательские службы устанавливаются после настройки KeyboardKit,
            // поскольку сама библиотека во время настройки заменяет стандартные службы.
            self.state.keyboardContext.locale = .russian
            self.services.actionHandler = MyKeyboardActionHandler(controller: self)
            self.services.autocompleteService = MyAutocompleteProvider()

            if case .failure(let error) = result {
                // Даже при ошибке необязательной настройки расширение продолжает работать
                // на явно установленных выше службах и не оставляет пользователя без клавиатуры.
                NSLog("Не удалось полностью настроить KeyboardKit: \(error)")
            }
        }
    }

    override func viewWillSetupKeyboardView() {
        setupKeyboardView { controller in
            KeyboardView(
                services: controller.services,
                state: controller.state
            )
        }
    }
}

private extension KeyboardApp {

    static let kamyal = KeyboardApp(
        name: "Къамаьл",
        appGroupId: Config.APP_GROUP_NAME,
        locales: [.russian]
    )
}
