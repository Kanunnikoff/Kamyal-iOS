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
        // Зафиксированный Shift относится ко всему выбранному слову, а не только
        // к уже введённому фрагменту. Проверяем его раньше нормативных исключений,
        // чтобы в этом режиме любая подсказка была полностью в верхнем регистре.
        if isUppercaseLocked {
            return word.uppercased(with: locale)
        }

        let normalizedWord = word.lowercased(with: locale)

        // Частотный словарь собран из корпуса и содержит отдельные формы имени
        // Всевышнего со строчной буквы. Для подсказок сохраняем нормативный регистр
        // независимо от того, с какой буквы пользователь начал вводить слово.
        if canonicalUppercasePrefixes.contains(where: normalizedWord.hasPrefix) {
            return word.capitalized(with: locale)
        }

        return input.first?.isUppercase == true
            ? word.capitalized(with: locale)
            : word
    }
}

actor IngushDictionary {

    private enum Source: Hashable {

        case dictionary
        case names

        var fileName: String {
            switch self {
                case .dictionary:
                    "ing_freq_dict_sorted"
                case .names:
                    "ing_names"
            }
        }

        var fileExtension: String {
            switch self {
                case .dictionary:
                    "csv"
                case .names:
                    "txt"
            }
        }
    }

    private static let byteOrderMark: Character = "\u{FEFF}"
    private static let fieldSeparator: Character = ";"
    private static let indexedPrefixLength = 2
    private static let cancellationCheckInterval = 256
    private static let locale = Locale(identifier: "ru")

    private struct Storage {

        let words: [String]
        let positionsByPrefix: [String: [Int]]
    }

    private let customURLs: [Source: URL]
    private var cachedStorages: [Source: Storage] = [:]

    init(
        dictionaryURL: URL? = nil,
        namesURL: URL? = nil
    ) {
        var customURLs: [Source: URL] = [:]
        customURLs[.dictionary] = dictionaryURL
        customURLs[.names] = namesURL
        self.customURLs = customURLs
    }

    func prepare() {
        _ = loadStorageIfNeeded(for: .dictionary)
        _ = loadStorageIfNeeded(for: .names)
    }

    func suggestions(
        for input: String,
        limit: Int
    ) throws -> [String] {
        guard !input.isEmpty, limit > 0 else { return [] }

        try Task.checkCancellation()

        let normalizedInput = input.lowercased(with: Self.locale)
        let dictionarySuggestions = try suggestions(
            in: loadStorageIfNeeded(for: .dictionary),
            matching: normalizedInput,
            limit: limit,
            excluding: []
        )
        let remainingSuggestionCount = limit - dictionarySuggestions.count

        guard remainingSuggestionCount > 0 else { return dictionarySuggestions }

        // Частотный словарь сохраняет приоритет, а имена занимают только оставшиеся
        // места. Сравнение без учёта регистра не позволяет показать одно и то же
        // слово дважды, если оно присутствует в обоих источниках.
        let normalizedDictionarySuggestions = Set(
            dictionarySuggestions.map { $0.lowercased(with: Self.locale) }
        )
        let nameSuggestions = try suggestions(
            in: loadStorageIfNeeded(for: .names),
            matching: normalizedInput,
            limit: remainingSuggestionCount,
            excluding: normalizedDictionarySuggestions
        )

        return dictionarySuggestions + nameSuggestions
    }
}

private extension IngushDictionary {

    private func loadStorageIfNeeded(for source: Source) -> Storage {
        if let cachedStorage = cachedStorages[source] {
            return cachedStorage
        }

        let storage = loadStorage(for: source)
        cachedStorages[source] = storage
        return storage
    }

    private func loadStorage(for source: Source) -> Storage {
        let bundledURL = Bundle.main.url(
            forResource: source.fileName,
            withExtension: source.fileExtension
        )

        guard let url = customURLs[source] ?? bundledURL else {
            assertionFailure("Не найден файл словаря: \(source.fileName).\(source.fileExtension).")
            return Storage(words: [], positionsByPrefix: [:])
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let words = content
                .components(separatedBy: .newlines)
                .compactMap { line -> String? in
                    guard var word = line.split(separator: Self.fieldSeparator).first else {
                        return nil
                    }

                    // Файл имён сохранён с меткой порядка байтов. Убираем её из
                    // первого имени, иначе невидимый символ помешает поиску по нему.
                    if word.first == Self.byteOrderMark {
                        word = word.dropFirst()
                    }

                    return word.isEmpty ? nil : String(word)
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
            assertionFailure(
                "Не удалось прочитать файл словаря \(source.fileName).\(source.fileExtension): \(error)"
            )
            return Storage(words: [], positionsByPrefix: [:])
        }
    }

    private func indexedPrefix(for text: String) -> String? {
        guard text.count >= Self.indexedPrefixLength else { return nil }

        return String(text.prefix(Self.indexedPrefixLength))
    }

    private func suggestions(
        in storage: Storage,
        matching normalizedInput: String,
        limit: Int,
        excluding normalizedExcludedWords: Set<String>
    ) throws -> [String] {
        if let indexedPrefix = indexedPrefix(for: normalizedInput) {
            guard let positions = storage.positionsByPrefix[indexedPrefix] else { return [] }

            return try suggestions(
                at: positions,
                in: storage,
                matching: normalizedInput,
                limit: limit,
                excluding: normalizedExcludedWords
            )
        }

        return try suggestions(
            at: storage.words.indices,
            in: storage,
            matching: normalizedInput,
            limit: limit,
            excluding: normalizedExcludedWords
        )
    }

    private func suggestions<Positions: Sequence>(
        at positions: Positions,
        in storage: Storage,
        matching normalizedInput: String,
        limit: Int,
        excluding normalizedExcludedWords: Set<String>
    ) throws -> [String] where Positions.Element == Int {
        var result: [String] = []
        result.reserveCapacity(limit)
        var normalizedResultWords = normalizedExcludedWords

        for (offset, position) in positions.enumerated() {
            // Поиск по редкому началу слова всё ещё может просмотреть большой раздел
            // словаря. Периодическая проверка позволяет немедленно прекратить уже
            // неактуальный запрос, когда пользователь успел ввести следующую букву.
            if offset.isMultiple(of: Self.cancellationCheckInterval) {
                try Task.checkCancellation()
            }

            let word = storage.words[position]
            let normalizedWord = word.lowercased(with: Self.locale)
            guard normalizedWord.hasPrefix(normalizedInput) else { continue }
            guard normalizedResultWords.insert(normalizedWord).inserted else { continue }

            result.append(word)

            if result.count == limit {
                break
            }
        }

        return result
    }
}
