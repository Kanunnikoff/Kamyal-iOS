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
    
    private func calloutActionStrings(for char: String) -> [String] {
        switch char {
            case "0": return ["0", "°"]
                
            case "а": return ["а", "аь", "а́", "ă"]
            case "г": return ["г", "гӀ"]
            case "е": return ["е", "ё", "е́"]
            case "и": return ["и", "и́"]
            case "к": return ["к", "кх", "къ", "кӀ"]
            case "о": return ["о", "о́"]
            case "п": return ["п", "пӀ"]
            case "т": return ["т", "тӀ"]
            case "у": return ["у", "у́"]
            case "х": return ["х", "хь", "хӀ"]
            case "ц": return ["ц", "цӀ"]
            case "ч": return ["ч", "чӀ"]
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
