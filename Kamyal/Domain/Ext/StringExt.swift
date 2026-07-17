//
//  StringExt.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 05.10.2022.
//

import Foundation

private enum IngushPalochka {

    static let canonical = "Ӏ"
    static let formalLowercase = "ӏ"
}

extension String {
    
    public func hasPrefixIgnoringCase(_ prefix: String) -> Bool {
        range(of: prefix, options: [.anchored, .caseInsensitive]) != nil
    }

    /// Возвращает принятую в современном ингушском алфавите безрегистровую
    /// палочку U+04C0. Стандартные преобразования регистра Foundation заменяют
    /// её на формальную строчную U+04CF, поэтому нормализацию следует выполнять
    /// после `lowercased`, `uppercased` или `capitalized`.
    public func canonicalizingIngushPalochka() -> String {
        replacingOccurrences(
            of: IngushPalochka.formalLowercase,
            with: IngushPalochka.canonical
        )
    }
}
