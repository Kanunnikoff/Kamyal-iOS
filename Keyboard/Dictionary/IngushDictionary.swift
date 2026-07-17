//
//  IngushDictionary.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation

enum IngushSuggestionFormatter {

    private static let canonicalUppercasePrefixes = ["аллахӏ"]
    private static let locale = Locale(identifier: "ru")

    static func format(
        _ word: String,
        for input: String,
        isUppercaseLocked: Bool
    ) -> String {
        let formattedWord: String

        // Зафиксированный Shift относится ко всему выбранному слову, а не только
        // к уже введённому фрагменту. Проверяем его раньше нормативных исключений,
        // чтобы в этом режиме любая подсказка была полностью в верхнем регистре.
        if isUppercaseLocked {
            formattedWord = word.uppercased(with: locale)
        } else {
            let normalizedWord = word.lowercased(with: locale)

            // Частотный словарь собран из корпуса и содержит отдельные формы имени
            // Всевышнего со строчной буквы. Для подсказок сохраняем нормативный регистр
            // независимо от того, с какой буквы пользователь начал вводить слово.
            if canonicalUppercasePrefixes.contains(where: normalizedWord.hasPrefix) {
                formattedWord = word.capitalized(with: locale)
            } else {
                formattedWord = input.first?.isUppercase == true
                    ? word.capitalized(with: locale)
                    : word
            }
        }

        // Корпус словаря и системные операции регистра используют U+04CF.
        // Наружу всегда отдаём принятую в ингушском алфавите форму U+04C0.
        return formattedWord.canonicalizingIngushPalochka()
    }
}

actor IngushDictionary {

    private static let fileExtension = "csv"
    private static let fileName = "ing_freq_dict_sorted"
    private static let fieldSeparator: Character = ";"
    private static let indexedPrefixLength = 2
    private static let cancellationCheckInterval = 256
    private static let locale = Locale(identifier: "ru")

    private struct Storage {

        let words: [String]
        let positionsByPrefix: [String: [Int]]
    }

    private let dictionaryURL: URL?
    private var cachedStorage: Storage?

    init(dictionaryURL: URL? = nil) {
        self.dictionaryURL = dictionaryURL
    }

    func prepare() {
        _ = loadStorageIfNeeded()
    }

    func suggestions(
        for input: String,
        limit: Int
    ) throws -> [String] {
        guard !input.isEmpty, limit > 0 else { return [] }

        try Task.checkCancellation()

        let storage = loadStorageIfNeeded()
        let normalizedInput = input.lowercased(with: Self.locale)

        if let indexedPrefix = indexedPrefix(for: normalizedInput) {
            guard let positions = storage.positionsByPrefix[indexedPrefix] else { return [] }

            return try suggestions(
                in: positions,
                storage: storage,
                matching: normalizedInput,
                limit: limit
            )
        }

        return try suggestions(
            in: storage.words.indices,
            storage: storage,
            matching: normalizedInput,
            limit: limit
        )
    }
}

private extension IngushDictionary {

    private func loadStorageIfNeeded() -> Storage {
        if let cachedStorage {
            return cachedStorage
        }

        let storage = loadStorage()
        cachedStorage = storage
        return storage
    }

    private func loadStorage() -> Storage {
        let bundledURL = Bundle.main.url(
            forResource: Self.fileName,
            withExtension: Self.fileExtension
        )

        guard let url = dictionaryURL ?? bundledURL else {
            assertionFailure("Не найден файл ингушского словаря.")
            return Storage(words: [], positionsByPrefix: [:])
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let words = content
                .components(separatedBy: .newlines)
                .compactMap { line in
                    line.split(separator: Self.fieldSeparator).first.map(String.init)
                }

            var positionsByPrefix: [String: [Int]] = [:]

            for (position, word) in words.enumerated() {
                let normalizedWord = word.lowercased(with: Self.locale)
                guard let prefix = indexedPrefix(for: normalizedWord) else { continue }

                positionsByPrefix[prefix, default: []].append(position)
            }

            return Storage(
                words: words,
                positionsByPrefix: positionsByPrefix
            )
        } catch {
            assertionFailure("Не удалось прочитать ингушский словарь: \(error)")
            return Storage(words: [], positionsByPrefix: [:])
        }
    }

    private func indexedPrefix(for text: String) -> String? {
        guard text.count >= Self.indexedPrefixLength else { return nil }

        return String(text.prefix(Self.indexedPrefixLength))
    }

    private func suggestions<Positions: Sequence>(
        in positions: Positions,
        storage: Storage,
        matching normalizedInput: String,
        limit: Int
    ) throws -> [String] where Positions.Element == Int {
        var result: [String] = []
        result.reserveCapacity(limit)

        for (offset, position) in positions.enumerated() {
            // Поиск по редкому началу слова всё ещё может просмотреть большой раздел
            // словаря. Периодическая проверка позволяет немедленно прекратить уже
            // неактуальный запрос, когда пользователь успел ввести следующую букву.
            if offset.isMultiple(of: Self.cancellationCheckInterval) {
                try Task.checkCancellation()
            }

            let word = storage.words[position]
            guard word.lowercased(with: Self.locale).hasPrefix(normalizedInput) else { continue }

            result.append(word)

            if result.count == limit {
                break
            }
        }

        return result
    }
}
