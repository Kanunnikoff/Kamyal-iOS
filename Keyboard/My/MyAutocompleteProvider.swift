//
//  MyAutocompleteProvider.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation
import KeyboardKit

final class MyAutocompleteProvider: AutocompleteService {

    private static let maxSuggestionCount = 3

    private let dictionary = IngushDictionary()
    private let userDefaults = UserDefaults(suiteName: Config.APP_GROUP_NAME) ?? .standard

    var locale: Locale = .russian

    init() {
        Task(priority: .userInitiated) { [dictionary] in
            // Построение указателя начинается при открытии клавиатуры, поэтому первый
            // введённый слог не ждёт чтения всего частотного словаря с диска.
            await dictionary.prepare()
        }
    }

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
        let suggestions = words.map { word in
            AutocompleteSuggestion(
                text: IngushSuggestionFormatter.format(
                    word,
                    for: query
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

    func hasIgnoredWord(_ word: String) -> Bool { false }
    func hasLearnedWord(_ word: String) -> Bool { false }
    func ignoreWord(_ word: String) {}
    func learnWord(_ word: String) {}
    func removeIgnoredWord(_ word: String) {}
    func unlearnWord(_ word: String) {}
}

private extension MyAutocompleteProvider {

    var isKeyboardLatin: Bool {
        userDefaults.bool(forKey: KeyboardSettingsKey.isKeyboardLatin)
    }
}
