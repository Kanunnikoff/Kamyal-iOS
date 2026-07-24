//
//  MyAutocompleteProvider.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation
import KeyboardKit

/// Формирует подсказки из встроенного ингушского словаря для KeyboardKit.
final class MyAutocompleteProvider: AutocompleteService {

    private static let maxSuggestionCount = 3

    private let dictionary = IngushDictionary()
    private let keyboardContext: KeyboardContext
    private let userDefaults = UserDefaults(suiteName: Config.APP_GROUP_NAME) ?? .standard

    var locale: Locale = .russian

    /// Создаёт службу подсказок и начинает предварительную подготовку словаря.
    ///
    /// - Parameter keyboardContext: Состояние клавиатуры, необходимое для выбора регистра.
    init(keyboardContext: KeyboardContext) {
        self.keyboardContext = keyboardContext

        Task(priority: .userInitiated) { [dictionary] in
            // Построение указателя начинается при открытии клавиатуры, поэтому первый
            // введённый слог не ждёт чтения всего частотного словаря с диска.
            await dictionary.prepare()
        }
    }

    /// Возвращает до трёх словарных подсказок для текущего фрагмента слова.
    ///
    /// - Parameter text: Текст перед курсором, переданный KeyboardKit.
    /// - Returns: Результат с исходным текстом запроса и подходящими словами.
    /// - Throws: `CancellationError`, если запрос потерял актуальность.
    func autocomplete(_ text: String) async throws -> AutocompleteResult {
        guard !isKeyboardLatin else {
            return AutocompleteResult(
                inputText: text,
                suggestions: []
            )
        }

        // KeyboardKit 10 передаёт сюда весь доступный фрагмент текста перед
        // курсором, а не только набираемое слово. Для поиска используем последнее
        // незавершённое слово, но в результате сохраняем исходный `text`: библиотека
        // сопоставляет его с запросом и отбрасывает успевшие устареть ответы.
        let query = text.wordFragmentAtEnd
        guard !query.isEmpty else {
            return AutocompleteResult(
                inputText: text,
                suggestions: []
            )
        }

        let words = try await dictionary.suggestions(
            for: query,
            limit: Self.maxSuggestionCount
        )
        let isUppercaseLocked = keyboardContext.keyboardCase == .capsLocked
        let suggestions = words.map { word in
            AutocompleteSuggestion(
                text: IngushSuggestionFormatter.format(
                    word,
                    for: query,
                    isUppercaseLocked: isUppercaseLocked
                )
            )
        }

        return AutocompleteResult(
            inputText: text,
            suggestions: Array(suggestions)
        )
    }

    var canIgnoreWords: Bool { false }
    var canLearnWords: Bool { false }
    var ignoredWords: [String] { [] }
    var learnedWords: [String] { [] }

    /// Сообщает, что служба не хранит игнорируемые слова.
    ///
    /// - Parameter word: Проверяемое слово.
    /// - Returns: Всегда `false`.
    func hasIgnoredWord(_ word: String) -> Bool { false }

    /// Сообщает, что служба не хранит выученные слова.
    ///
    /// - Parameter word: Проверяемое слово.
    /// - Returns: Всегда `false`.
    func hasLearnedWord(_ word: String) -> Bool { false }

    /// Не изменяет словарь, поскольку игнорирование слов не поддерживается.
    ///
    /// - Parameter word: Слово, которое запрашивает KeyboardKit.
    func ignoreWord(_ word: String) {}

    /// Не изменяет словарь, поскольку обучение не поддерживается.
    ///
    /// - Parameter word: Слово, которое запрашивает KeyboardKit.
    func learnWord(_ word: String) {}

    /// Не изменяет словарь, поскольку список игнорируемых слов отсутствует.
    ///
    /// - Parameter word: Слово, которое запрашивает KeyboardKit.
    func removeIgnoredWord(_ word: String) {}

    /// Не изменяет словарь, поскольку список выученных слов отсутствует.
    ///
    /// - Parameter word: Слово, которое запрашивает KeyboardKit.
    func unlearnWord(_ word: String) {}
}

private extension MyAutocompleteProvider {

    var isKeyboardLatin: Bool {
        userDefaults.bool(forKey: KeyboardSettingsKey.isKeyboardLatin)
    }
}
