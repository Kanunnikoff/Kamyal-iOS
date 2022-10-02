//
//  Pre1917RussianInputSetProvider.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import Foundation
import KeyboardKit

/**
 This input set provider provides Pre-Revolutionary Russian input sets.
 */
public class VaynakhInputSetProvider: InputSetProvider, LocalizedService {
    
    /**
     Create an English input set provider.
     
     - Parameters:
     - numericCurrency: The currency to use for the numeric input set.
     - symbolicCurrency: The currency to use for the symbolic input set.
     */
    public init(
        numericCurrency: String = "₽",
        symbolicCurrency: String = "€") {
            self.numericCurrency = numericCurrency
            self.symbolicCurrency = symbolicCurrency
        }
    
    /**
     The currency to use for the numeric input set.
     */
    public let numericCurrency: String
    
    /**
     The currency to use for the symbolic input set.
     */
    public let symbolicCurrency: String
    
    /**
     The locale identifier.
     */
    public let localeKey: String = KeyboardLocale.russian.id
    
    /**
     The input set to use for alphabetic keyboards.
     */
    public var alphabeticInputSet: AlphabeticInputSet {
        AlphabeticInputSet(rows: [
            InputSetRow("йцукенгшщзх"),
            InputSetRow("фывапролджэ"),
            InputSetRow(phone: "ячсмитьбю", pad: "ячсмитьбюъ")
        ])
    }
    
    /**
     The input set to use for numeric keyboards.
     */
    public var numericInputSet: NumericInputSet {
        NumericInputSet(rows: [
            InputSetRow("1234567890"),
            InputSetRow(phone: "-/:;()\(numericCurrency)&@”", pad: "@#\(numericCurrency)&*()’”"),
            InputSetRow(phone: ".,?!’", pad: "%-+=/;:!?")
        ])
    }
    
    /**
     The input set to use for symbolic keyboards.
     */
    public var symbolicInputSet: SymbolicInputSet {
        SymbolicInputSet(rows: [
            InputSetRow(phone: "[]{}#%^*+=", pad: "1234567890"),
            InputSetRow(phone: "_\\|~<>$\(symbolicCurrency)£•", pad: "€\(symbolicCurrency)¥_^[]{}"),
            InputSetRow(phone: ".,?!’", pad: "§|~…\\<>!?")
        ])
    }
}
