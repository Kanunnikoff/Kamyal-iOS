//
//  StringExt.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 05.10.2022.
//

import Foundation

extension String {
    
    public func hasPrefixIgnoringCase(_ prefix: String) -> Bool {
        range(of: prefix, options: [.anchored, .caseInsensitive]) != nil
    }
}
