//
//  GlobalFunc.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 05.10.2022.
//

import Foundation

/// Асинхронно выполняет блок в общей фоновой очереди.
///
/// - Parameter block: Работа, не требующая главной очереди.
func BG(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: block)
}

/// Асинхронно выполняет блок в главной очереди.
///
/// - Parameter block: Работа с состоянием или интерфейсом приложения.
func UI(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
