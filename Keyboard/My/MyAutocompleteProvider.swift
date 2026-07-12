//
//  MyAutocompleteProvider.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation
import KeyboardKit

final class MyAutocompleteProvider: AutocompleteService {

    private static let debounceNanoseconds: UInt64 = 100_000_000
    private static let maxSuggestionCount = 3

    private let dictionary = IngushDictionary()
    private let userDefaults = UserDefaults(suiteName: Config.APP_GROUP_NAME) ?? .standard

    var locale: Locale = .russian

    func autocomplete(_ text: String) async throws -> AutocompleteResult {
        try await Task.sleep(nanoseconds: Self.debounceNanoseconds)

        guard !isKeyboardLatin else {
            return AutocompleteResult(
                inputText: text,
                suggestions: []
            )
        }

        let words = await dictionary.words()
        let suggestions = words.lazy
            .filter { word in
                word.hasPrefixIgnoringCase(text)
            }
            .prefix(Self.maxSuggestionCount)
            .map { word in
                let suggestion = text.isCapitalized
                    ? word.capitalized(with: .russian)
                    : word
                return AutocompleteSuggestion(text: suggestion)
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
