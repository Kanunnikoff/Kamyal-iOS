//
//  AlphabetView.swift
//  Kamyal
//
//  Created by Codex on 17.07.2026.
//

import SwiftUI

struct AlphabetView: View {

    fileprivate enum Layout {

        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
        static let gridSpacing: CGFloat = 12
        static let minimumLetterCardWidth: CGFloat = 72
        static let letterCardHeight: CGFloat = 76
        static let letterCardCornerRadius: CGFloat = 12
    }

    @State private var selectedScript: AlphabetScript = .cyrillic

    private let gridColumns = [
        GridItem(
            .adaptive(minimum: Layout.minimumLetterCardWidth),
            spacing: Layout.gridSpacing
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Picker("Письменность", selection: $selectedScript) {
                ForEach(AlphabetScript.allCases) { script in
                    Text(script.title)
                        .tag(script)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.verticalPadding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedScript.heading)
                            .font(.headline)

                        Text(selectedScript.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: gridColumns, spacing: Layout.gridSpacing) {
                        ForEach(selectedScript.letters) { letter in
                            AlphabetLetterView(letter: letter)
                        }
                    }

                    Text(selectedScript.note)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Link(destination: AlphabetData.sourceURL) {
                        Label("Источник: «Ингушская письменность»", systemImage: "arrow.up.right.square")
                            .font(.footnote)
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.vertical, Layout.verticalPadding)
            }
        }
        .navigationTitle("Алфавит")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AlphabetLetterView: View {

    let letter: AlphabetLetter

    var body: some View {
        VStack(spacing: 2) {
            Text(letter.uppercase)
                .font(.title2.weight(.semibold))

            if let lowercase = letter.lowercase {
                Text(lowercase)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                // У буквы Ӏ одна и та же форма в обоих регистрах. Пустая строка
                // сохраняет одинаковую высоту карточек, не создавая вторую форму.
                Text(" ")
                    .font(.subheadline)
                    .accessibilityHidden(true)
            }
        }
        .minimumScaleFactor(0.75)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .frame(height: AlphabetView.Layout.letterCardHeight)
        .background {
            RoundedRectangle(cornerRadius: AlphabetView.Layout.letterCardCornerRadius)
                .fill(Color.secondary.opacity(0.12))
        }
        .accessibilityElement(children: .combine)
    }
}

private enum AlphabetScript: String, CaseIterable, Identifiable {

    case cyrillic
    case latin

    var id: Self { self }

    var title: String {
        switch self {
            case .cyrillic:
                "Кириллица"
            case .latin:
                "Латиница"
        }
    }

    var heading: String {
        switch self {
            case .cyrillic:
                "Современный алфавит"
            case .latin:
                "Алфавит 1934 года"
        }
    }

    var description: String {
        switch self {
            case .cyrillic:
                "Заглавные и строчные формы букв и буквосочетаний."
            case .latin:
                "Последний официальный вариант ингушской латиницы, использовавшийся до 1938 года."
        }
    }

    var note: String {
        switch self {
            case .cyrillic:
                "Ё, Щ, Ы и самостоятельная Ь встречаются только в заимствованных словах."
            case .latin:
                "В изданиях 1934–1937 годов буквы Ꞑ ꞑ, Ö ö и Ü ü фактически не использовались."
        }
    }

    var letters: [AlphabetLetter] {
        switch self {
            case .cyrillic:
                AlphabetData.cyrillicLetters
            case .latin:
                AlphabetData.latinLetters
        }
    }
}

private struct AlphabetLetter: Identifiable {

    let uppercase: String
    let lowercase: String?

    var id: String { uppercase }
}

private enum AlphabetData {

    static let sourceURL = URL(
        string: "https://ru.wikipedia.org/wiki/%D0%98%D0%BD%D0%B3%D1%83%D1%88%D1%81%D0%BA%D0%B0%D1%8F_%D0%BF%D0%B8%D1%81%D1%8C%D0%BC%D0%B5%D0%BD%D0%BD%D0%BE%D1%81%D1%82%D1%8C"
    )!

    static let cyrillicLetters: [AlphabetLetter] = [
        AlphabetLetter(uppercase: "А", lowercase: "а"),
        AlphabetLetter(uppercase: "Аь", lowercase: "аь"),
        AlphabetLetter(uppercase: "Б", lowercase: "б"),
        AlphabetLetter(uppercase: "В", lowercase: "в"),
        AlphabetLetter(uppercase: "Г", lowercase: "г"),
        AlphabetLetter(uppercase: "ГӀ", lowercase: "гӀ"),
        AlphabetLetter(uppercase: "Д", lowercase: "д"),
        AlphabetLetter(uppercase: "Е", lowercase: "е"),
        AlphabetLetter(uppercase: "Ё", lowercase: "ё"),
        AlphabetLetter(uppercase: "Ж", lowercase: "ж"),
        AlphabetLetter(uppercase: "З", lowercase: "з"),
        AlphabetLetter(uppercase: "И", lowercase: "и"),
        AlphabetLetter(uppercase: "Й", lowercase: "й"),
        AlphabetLetter(uppercase: "К", lowercase: "к"),
        AlphabetLetter(uppercase: "Кх", lowercase: "кх"),
        AlphabetLetter(uppercase: "Къ", lowercase: "къ"),
        AlphabetLetter(uppercase: "КӀ", lowercase: "кӀ"),
        AlphabetLetter(uppercase: "Л", lowercase: "л"),
        AlphabetLetter(uppercase: "М", lowercase: "м"),
        AlphabetLetter(uppercase: "Н", lowercase: "н"),
        AlphabetLetter(uppercase: "О", lowercase: "о"),
        AlphabetLetter(uppercase: "П", lowercase: "п"),
        AlphabetLetter(uppercase: "ПӀ", lowercase: "пӀ"),
        AlphabetLetter(uppercase: "Р", lowercase: "р"),
        AlphabetLetter(uppercase: "С", lowercase: "с"),
        AlphabetLetter(uppercase: "Т", lowercase: "т"),
        AlphabetLetter(uppercase: "ТӀ", lowercase: "тӀ"),
        AlphabetLetter(uppercase: "У", lowercase: "у"),
        AlphabetLetter(uppercase: "Ф", lowercase: "ф"),
        AlphabetLetter(uppercase: "Х", lowercase: "х"),
        AlphabetLetter(uppercase: "Хь", lowercase: "хь"),
        AlphabetLetter(uppercase: "ХӀ", lowercase: "хӀ"),
        AlphabetLetter(uppercase: "Ц", lowercase: "ц"),
        AlphabetLetter(uppercase: "ЦӀ", lowercase: "цӀ"),
        AlphabetLetter(uppercase: "Ч", lowercase: "ч"),
        AlphabetLetter(uppercase: "ЧӀ", lowercase: "чӀ"),
        AlphabetLetter(uppercase: "Ш", lowercase: "ш"),
        AlphabetLetter(uppercase: "Щ", lowercase: "щ"),
        AlphabetLetter(uppercase: "Ъ", lowercase: "ъ"),
        AlphabetLetter(uppercase: "Ы", lowercase: "ы"),
        AlphabetLetter(uppercase: "Ь", lowercase: "ь"),
        AlphabetLetter(uppercase: "Э", lowercase: "э"),
        AlphabetLetter(uppercase: "Ю", lowercase: "ю"),
        AlphabetLetter(uppercase: "Я", lowercase: "я"),
        AlphabetLetter(uppercase: "Яь", lowercase: "яь"),
        AlphabetLetter(uppercase: "Ӏ", lowercase: nil)
    ]

    // В статье приведено несколько исторических вариантов. Здесь используется
    // последний официальный алфавит 1934 года, действовавший до перехода на кириллицу.
    static let latinLetters: [AlphabetLetter] = [
        AlphabetLetter(uppercase: "A", lowercase: "a"),
        AlphabetLetter(uppercase: "B", lowercase: "b"),
        AlphabetLetter(uppercase: "V", lowercase: "v"),
        AlphabetLetter(uppercase: "G", lowercase: "g"),
        AlphabetLetter(uppercase: "D", lowercase: "d"),
        AlphabetLetter(uppercase: "Je", lowercase: "je"),
        AlphabetLetter(uppercase: "E", lowercase: "e"),
        AlphabetLetter(uppercase: "Ž", lowercase: "ž"),
        AlphabetLetter(uppercase: "Z", lowercase: "z"),
        AlphabetLetter(uppercase: "I", lowercase: "i"),
        AlphabetLetter(uppercase: "J", lowercase: "j"),
        AlphabetLetter(uppercase: "K", lowercase: "k"),
        AlphabetLetter(uppercase: "L", lowercase: "l"),
        AlphabetLetter(uppercase: "M", lowercase: "m"),
        AlphabetLetter(uppercase: "N", lowercase: "n"),
        AlphabetLetter(uppercase: "Ꞑ", lowercase: "ꞑ"),
        AlphabetLetter(uppercase: "O", lowercase: "o"),
        AlphabetLetter(uppercase: "P", lowercase: "p"),
        AlphabetLetter(uppercase: "R", lowercase: "r"),
        AlphabetLetter(uppercase: "S", lowercase: "s"),
        AlphabetLetter(uppercase: "T", lowercase: "t"),
        AlphabetLetter(uppercase: "U", lowercase: "u"),
        AlphabetLetter(uppercase: "F", lowercase: "f"),
        AlphabetLetter(uppercase: "X", lowercase: "x"),
        AlphabetLetter(uppercase: "C", lowercase: "c"),
        AlphabetLetter(uppercase: "Č", lowercase: "č"),
        AlphabetLetter(uppercase: "Š", lowercase: "š"),
        AlphabetLetter(uppercase: "Ju", lowercase: "ju"),
        AlphabetLetter(uppercase: "Ja", lowercase: "ja"),
        AlphabetLetter(uppercase: "H", lowercase: "h"),
        AlphabetLetter(uppercase: "Gh", lowercase: "gh"),
        AlphabetLetter(uppercase: "Kh", lowercase: "kh"),
        AlphabetLetter(uppercase: "Ph", lowercase: "ph"),
        AlphabetLetter(uppercase: "Th", lowercase: "th"),
        AlphabetLetter(uppercase: "Ch", lowercase: "ch"),
        AlphabetLetter(uppercase: "Čh", lowercase: "čh"),
        AlphabetLetter(uppercase: "Q", lowercase: "q"),
        AlphabetLetter(uppercase: "Qh", lowercase: "qh"),
        AlphabetLetter(uppercase: "Ꜧ", lowercase: "ꜧ"),
        AlphabetLetter(uppercase: "Ä", lowercase: "ä"),
        AlphabetLetter(uppercase: "Ö", lowercase: "ö"),
        AlphabetLetter(uppercase: "Ü", lowercase: "ü")
    ]
}

struct AlphabetView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            AlphabetView()
        }
    }
}
