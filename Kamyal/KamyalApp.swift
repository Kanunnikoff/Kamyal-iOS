//
//  KamyalApp.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import SwiftUI

/// Главная точка входа в приложение «Къамаьл».
@main
struct KamyalApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .shop()
        }
    }
}
