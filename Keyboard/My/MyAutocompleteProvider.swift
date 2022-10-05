//
//  MyAutocompleteProvider.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation
import KeyboardKit
import Combine

struct AutocompleteData {
    let text: String
    let completion: (AutocompleteResult) -> Void
}

final class MyAutocompleteProvider: AutocompleteProvider {
    
    private let dictionary = IngushDictionary()
    
    private let subject: PassthroughSubject = PassthroughSubject<AutocompleteData, Never>()
    private var cancellable: Cancellable? = nil
    
    public var locale: Locale = .current
    
    init() {
        cancellable = subject
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { data in
                self.createSuggestions(for: data.text, completion: data.completion)
            }
    }
    
    public func autocompleteSuggestions(for text: String, completion: @escaping (AutocompleteResult) -> Void) {
        subject.send(AutocompleteData(text: text, completion: completion))
    }
    
    private func createSuggestions(for text: String, completion: @escaping (AutocompleteResult) -> Void) {
        BG {
            let suggestions = self.dictionary.words
                .filter { word in
                    word.hasPrefix(text) || word.hasPrefix(text.lowercased())
                }
                .prefix(3)
                .map { text.isCapitalized ? $0.capitalized() : $0 }
                .map { StandardAutocompleteSuggestion($0) }
            
            UI {
                completion(.success(suggestions))
            }
        }
    }
    
    public var canIgnoreWords: Bool { false }
    public var canLearnWords: Bool { false }
    public var ignoredWords: [String] = []
    public var learnedWords: [String] = []
    
    public func hasIgnoredWord(_ word: String) -> Bool { false }
    public func hasLearnedWord(_ word: String) -> Bool { false }
    public func ignoreWord(_ word: String) {}
    public func learnWord(_ word: String) {}
    public func removeIgnoredWord(_ word: String) {}
    public func unlearnWord(_ word: String) {}
}
