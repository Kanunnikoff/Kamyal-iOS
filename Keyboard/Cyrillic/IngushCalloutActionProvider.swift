//
//  IngushCalloutActionProvider.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import Foundation
import KeyboardKit

/// Варианты ингушских кириллических букв и знаков по долгому нажатию.
struct IngushCalloutActionProvider {

    /// Возвращает варианты для всплывающего меню указанной клавиши.
    ///
    /// - Parameter action: Действие клавиши, для которого нужны варианты.
    /// - Returns: Действия с доступными символами или `nil`, если вариантов нет.
    func calloutActions(for action: KeyboardAction) -> [KeyboardAction]? {
        guard case .character(let character) = action else { return nil }

        let lowercaseCharacter = character.lowercased()
        let calloutStrings = calloutActionStrings(for: lowercaseCharacter)
        guard !calloutStrings.isEmpty else { return nil }

        // KeyboardKit передаёт в построитель уже преобразованную по регистру букву.
        // Составные варианты должны получить только первую заглавную букву, как и раньше.
        let strings = character.isUppercased
            ? calloutStrings.map { $0.capitalized(with: .russian) }
            : calloutStrings

        return strings.map { .character($0) }
    }

    /// Сопоставляет основной символ с вариантами кириллической раскладки.
    ///
    /// - Parameter char: Символ в нижнем регистре.
    /// - Returns: Упорядоченные варианты, включая исходный символ.
    private func calloutActionStrings(for char: String) -> [String] {
        switch char {
            case "0": return ["0", "°"]
                
            case "а": return ["а", "аь", "а́", "ă"]
            case "г": return ["г", "гӏ"]
            case "е": return ["е", "ё", "е́"]
            case "и": return ["и", "и́"]
            case "к": return ["к", "кх", "къ", "кӏ"]
            case "о": return ["о", "о́"]
            case "п": return ["п", "пӏ"]
            case "т": return ["т", "тӏ"]
            case "у": return ["у", "у́"]
            case "х": return ["х", "хь", "хӏ"]
            case "ц": return ["ц", "цӏ"]
            case "ч": return ["ч", "чӏ"]
            case "ш": return ["ш", "щ"]
            case "ь": return ["ь", "ъ"]
            case "ы": return ["ы", "ы́"]
            case "э": return ["э", "э́"]
            case "ю": return ["ю", "ю́"]
            case "я": return ["я", "я́"]
                
            case "-": return ["-", "–", "—", "•"]
            case "/": return ["/", "\\"]
            case "₽": return ["₽", "$", "€", "£", "¥", "₩"]
            case "&": return ["&", "§"]
            case "”", "“": return ["\"", "”", "“", "„", "»", "«"]
            case ".": return [".", "…"]
            case "?": return ["?", "¿"]
            case "!": return ["!", "¡"]
            case "'", "’": return ["'", "’", "‘", "`"]
                
            case "%": return ["%", "‰"]
            case "=": return ["=", "≠", "≈"]
                
            default: return []
        }
    }
}
