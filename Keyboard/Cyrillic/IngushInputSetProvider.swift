//
//  IngushInputSetProvider.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import Foundation
import KeyboardKit

/// Наборы символов для ингушской кириллической раскладки.
public struct IngushInputSetProvider {
    
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
        // Используем одинаковые ряды на телефоне и планшете: Щ доступна долгим
        // нажатием на Ш, а Ъ — долгим нажатием на Ь. Отдельные варианты для iPad
        // возвращали эти буквы в основной ряд и нарушали принятую раскладку.
        KeyboardLayout.InputSet(rows: [
            .init(chars: "йцукенгшӀзх"),
            .init(chars: "фывапролджэ"),
            .init(chars: "ячсмитьбю")
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
