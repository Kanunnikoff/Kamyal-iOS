//
//  Pre1917RussianCalloutActionProvider.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import Foundation
import KeyboardKit

/**
 This class provides Pre-Revolutionary Russian callout actions.
 
 You can use the class as a template when you want to create
 your own callout action provider.
 
 KeyboardKit Pro adds a provider for each ``KeyboardLocale``
 Check out the demo app to see them in action.
 */
class LatinVaynakhCalloutActionProvider: BaseCalloutActionProvider, LocalizedService {
    
    public let localeKey: String = KeyboardLocale.russian.id
    
    override func calloutActions(for char: String) -> [KeyboardAction] {
        let charValue = char.lowercased()
        let result = calloutActionStrings(for: charValue)
        let strings = char.isUppercased ? result.map{ $0.capitalized() } : result
        return strings.map { .character($0) }
    }
    
    private func calloutActionStrings(for char: String) -> [String] {
        switch char {
            case "0": return ["0", "°"]
                
            case "a": return ["a", "æ", "ä"]
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
            case "x": return ["x", "x́"]
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
