//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

class KeyboardViewController: KeyboardInputViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Основное приложение не может напрямую проверить системный переключатель
        // сторонней клавиатуры. Метка в общей группе подтверждает более полезный факт:
        // расширение хотя бы раз действительно появилось у пользователя на экране.
        UserDefaults(suiteName: Config.APP_GROUP_NAME)?.set(
            true,
            forKey: KeyboardSettingsKey.hasBeenUsed
        )
    }

    override func viewWillSetupKeyboardKit() {
        setupKeyboardKit(for: .kamyal) { [weak self] result in
            guard let self else { return }

            // Пользовательские службы устанавливаются после настройки KeyboardKit,
            // поскольку сама библиотека во время настройки заменяет стандартные службы.
            self.state.keyboardContext.locale = .russian

            let autocompleteService = MyAutocompleteProvider()
            self.services.autocompleteService = autocompleteService

            // Стандартный обработчик KeyboardKit сохраняет используемую службу
            // подсказок при создании. Поэтому сначала устанавливаем нашу службу,
            // а затем передаём тот же экземпляр обработчику явно.
            let actionHandler = MyKeyboardActionHandler(controller: self)
            actionHandler.autocompleteService = autocompleteService
            self.services.actionHandler = actionHandler

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
