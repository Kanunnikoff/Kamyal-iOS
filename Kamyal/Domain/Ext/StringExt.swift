//
//  StringExt.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 05.10.2022.
//

import Foundation

extension String {

    /// Проверяет начало строки без учёта регистра.
    ///
    /// - Parameter prefix: Ожидаемое начало строки.
    /// - Returns: `true`, если строка начинается с указанной последовательности.
    public func hasPrefixIgnoringCase(_ prefix: String) -> Bool {
        range(of: prefix, options: [.anchored, .caseInsensitive]) != nil
    }
}
