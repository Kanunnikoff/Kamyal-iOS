//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

class KeyboardViewController: KeyboardInputViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyAutocapitalizationSetting()
    }

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
            self.applyAutocapitalizationSetting()

            let autocompleteService = MyAutocompleteProvider()
            self.services.autocompleteService = autocompleteService

            // Стандартный обработчик KeyboardKit сохраняет используемую службу
            // подсказок при создании. Поэтому сначала устанавливаем нашу службу,
            // а затем передаём тот же экземпляр обработчику явно.
            let actionHandler = MyKeyboardActionHandler(controller: self)
            actionHandler.autocompleteService = autocompleteService
            actionHandler.isAutocapitalizationEnabled = self.isAutocapitalizationEnabled
            self.services.actionHandler = actionHandler

            if case .failure(let error) = result {
                // Даже при ошибке необязательной настройки расширение продолжает работать
                // на явно установленных выше службах и не оставляет пользователя без клавиатуры.
                NSLog("Не удалось полностью настроить KeyboardKit: \(error)")
            }
        }
    }

    override func viewWillSetupInitialKeyboardCase() {
        guard isAutocapitalizationEnabled else {
            setKeyboardCase(.lowercased)
            return
        }

        super.viewWillSetupInitialKeyboardCase()
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

private extension KeyboardViewController {

    var isAutocapitalizationEnabled: Bool {
        let userDefaults = UserDefaults(suiteName: Config.APP_GROUP_NAME)

        // Настройку меняет основное приложение в другом процессе. Перед чтением
        // обновляем общий домен, чтобы расширение не использовало старое значение.
        userDefaults?.synchronize()

        return userDefaults?.object(
            forKey: KeyboardSettingsKey.isAutocapitalizationEnabled
        ) as? Bool ?? true
    }

    func applyAutocapitalizationSetting() {
        let isEnabled = isAutocapitalizationEnabled

        // Основное приложение и расширение работают в разных процессах, поэтому
        // при каждом показе клавиатуры заново переносим значение из общей группы
        // в настройки KeyboardKit. Затем сразу пересчитываем регистр, иначе уже
        // показанная раскладка может сохранить прежнее состояние первой буквы.
        state.keyboardContext.settings.isAutocapitalizationEnabled = isEnabled

        (services.actionHandler as? MyKeyboardActionHandler)?
            .isAutocapitalizationEnabled = isEnabled

        setKeyboardCase(
            isEnabled
                ? preferredKeyboardCase(for: state.keyboardContext.locale)
                : .lowercased
        )
    }
}

private extension KeyboardApp {

    static let kamyal = KeyboardApp(
        name: "Къамаьл",
        appGroupId: Config.APP_GROUP_NAME,
        locales: [.russian]
    )
}
