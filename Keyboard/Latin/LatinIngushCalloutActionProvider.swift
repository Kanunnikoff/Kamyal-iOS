//
//  LatinIngushCalloutActionProvider.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import Foundation
import KeyboardKit

/// Варианты ингушских латинских букв и знаков по долгому нажатию.
struct LatinIngushCalloutActionProvider {

    func calloutActions(for action: KeyboardAction) -> [KeyboardAction]? {
        guard case .character(let character) = action else { return nil }

        let lowercaseCharacter = character.lowercased()
        let calloutStrings = calloutActionStrings(for: lowercaseCharacter)
        guard !calloutStrings.isEmpty else { return nil }

        // Для диграфов сохраняем прежнее поведение: в верхний регистр
        // переводится начало варианта, а не каждая входящая в него буква.
        let strings = character.isUppercased
            ? calloutStrings.map { $0.capitalized(with: .russian) }
            : calloutStrings

        return strings.map { .character($0) }
    }
    
    private func calloutActionStrings(for char: String) -> [String] {
        switch char {
            case "0": return ["0", "°"]
                
            case "a": return ["a", "æ", "ä", "ā"]
            case "c": return ["c", "č", "ch", "čh"]
            case "g": return ["g", "gh"]
            case "h": return ["h", "ꜧ"]
            case "k": return ["k", "kh"]
            case "n": return ["n", "ņ"]
            case "o": return ["o", "ö"]
            case "p": return ["p", "ph"]
            case "q": return ["q", "qh"]
            case "s": return ["s", "š"]
            case "t": return ["t", "th"]
            case "u": return ["u", "ü"]
            case "x": return ["x", "x́", "xh"]
            case "z": return ["z", "ž"]
                
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
