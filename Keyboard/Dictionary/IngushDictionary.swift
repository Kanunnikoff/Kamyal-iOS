//
//  IngushDictionary.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation

actor IngushDictionary {

    private static let fileExtension = "csv"
    private static let fileName = "ing_freq_dict_sorted"
    private static let fieldSeparator: Character = ";"

    private var cachedWords: [String]?

    func words() -> [String] {
        if let cachedWords {
            return cachedWords
        }

        let words = loadWords()
        cachedWords = words
        return words
    }
}

private extension IngushDictionary {

    func loadWords() -> [String] {
        guard let url = Bundle.main.url(
            forResource: Self.fileName,
            withExtension: Self.fileExtension
        ) else {
            assertionFailure("Не найден файл ингушского словаря.")
            return []
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content
                .components(separatedBy: .newlines)
                .compactMap { line in
                    line.split(separator: Self.fieldSeparator).first.map(String.init)
                }
        } catch {
            assertionFailure("Не удалось прочитать ингушский словарь: \(error)")
            return []
        }
    }
}
