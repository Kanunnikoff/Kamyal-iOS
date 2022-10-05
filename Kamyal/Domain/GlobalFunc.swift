//
//  GlobalFunc.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 05.10.2022.
//

import Foundation

func BG(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: block)
}

func UI(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
