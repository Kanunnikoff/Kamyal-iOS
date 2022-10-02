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
                
            case "a": return ["æ", "ä"]
            case "c": return ["č", "ch", "čh"]
            case "g": return ["gh"]
            case "h": return ["ꜧ"]
            case "k": return ["kh"]
            case "n": return ["ņ"]
            case "o": return ["ö"]
            case "p": return ["ph"]
            case "q": return ["qh"]
            case "s": return ["š"]
            case "t": return ["th"]
            case "u": return ["ü"]
            case "x": return ["x́"]
            case "z": return ["ž"]
                
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
