//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

/// Управляет жизненным циклом, службами и представлением расширения клавиатуры.
class KeyboardViewController: KeyboardInputViewController {

    /// Обновляет настройку автоматического регистра перед каждым появлением клавиатуры.
    ///
    /// - Parameter animated: Признак анимированного появления представления.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyAutocapitalizationSetting()
    }

    /// Отмечает в общей группе, что пользователь действительно открыл клавиатуру.
    ///
    /// - Parameter animated: Признак анимированного появления представления.
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

    /// Настраивает KeyboardKit и устанавливает службы подсказок и обработки действий.
    override func viewWillSetupKeyboardKit() {
        setupKeyboardKit(for: .kamyal) { [weak self] result in
            guard let self else { return }

            // Пользовательские службы устанавливаются после настройки KeyboardKit,
            // поскольку сама библиотека во время настройки заменяет стандартные службы.
            self.state.keyboardContext.locale = .russian
            self.applyAutocapitalizationSetting()

            let autocompleteService = MyAutocompleteProvider(
                keyboardContext: self.state.keyboardContext
            )
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

    /// Выбирает начальный регистр клавиатуры с учётом пользовательской настройки.
    override func viewWillSetupInitialKeyboardCase() {
        guard isAutocapitalizationEnabled else {
            setKeyboardCase(.lowercased)
            return
        }

        super.viewWillSetupInitialKeyboardCase()
    }

    /// Устанавливает корневое представление пользовательской клавиатуры.
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

    /// Переносит настройку автоматического регистра в службы KeyboardKit.
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
