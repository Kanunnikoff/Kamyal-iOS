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
class VaynakhCalloutActionProvider: BaseCalloutActionProvider, LocalizedService {
    
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
                
            case "а": return ["а", "аь"]
            case "г": return ["г", "гӀ"]
            case "е": return ["е", "ё"]
            case "и": return ["и", "Ӏ"]
            case "к": return ["к", "кх", "къ", "кӀ"]
            case "п": return ["п", "пӀ"]
            case "т": return ["т", "тӀ"]
            case "х": return ["х", "хь", "хӀ"]
            case "ц": return ["ц", "цӀ"]
            case "ч": return ["ч", "чӀ"]
            case "ь": return ["ь", "ъ"]
                
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
