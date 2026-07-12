//
//  LatinIngushInputSetProvider.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import Foundation
import KeyboardKit

/// Наборы символов для ингушской латинской раскладки.
public struct LatinIngushInputSetProvider {
    
    /// Создаёт наборы с указанными знаками валют для цифрового и символьного режимов.
    public init(
        numericCurrency: String = "₽",
        symbolicCurrency: String = "€") {
            self.numericCurrency = numericCurrency
            self.symbolicCurrency = symbolicCurrency
        }
    
    /// Знак валюты для цифрового режима.
    public let numericCurrency: String
    
    /// Знак валюты для символьного режима.
    public let symbolicCurrency: String
    
    /// Буквенные ряды для iPhone и iPad.
    public var alphabeticInputSet: KeyboardLayout.InputSet {
        KeyboardLayout.InputSet(rows: [
            .init(chars: "qertyuiop"),
            .init(chars: "asdfghjkl"),
            .init(chars: "zxcvbnm", deviceVariations: [.pad: "zxcvbnm,."])
        ])
    }
    
    /// Ряды цифрового режима.
    public var numericInputSet: KeyboardLayout.InputSet {
        KeyboardLayout.InputSet(rows: [
            .init(chars: "1234567890"),
            .init(
                chars: "-/:;()\(numericCurrency)&@”",
                deviceVariations: [.pad: "@#\(numericCurrency)&*()’”"]
            ),
            .init(chars: ".,?!’", deviceVariations: [.pad: "%-+=/;:!?"])
        ])
    }
    
    /// Ряды символьного режима.
    public var symbolicInputSet: KeyboardLayout.InputSet {
        KeyboardLayout.InputSet(rows: [
            .init(chars: "[]{}#%^*+=", deviceVariations: [.pad: "1234567890"]),
            .init(
                chars: "_\\|~<>$\(symbolicCurrency)£•",
                deviceVariations: [.pad: "€\(symbolicCurrency)¥_^[]{}"]
            ),
            .init(chars: ".,?!’", deviceVariations: [.pad: "§|~…\\<>!?"])
        ])
    }
}
