//
//  AppDelegate.swift
//  Kamyal
//
//  Created by Codex on 20.07.2026.
//

import FirebaseCore
import UIKit

/// Делегат приложения, который настраивает общие службы при запуске.
final class AppDelegate: NSObject, UIApplicationDelegate {

    /// Инициализирует Firebase после завершения запуска приложения.
    ///
    /// - Parameters:
    ///   - application: Запущенный экземпляр приложения.
    ///   - launchOptions: Причины и дополнительные сведения о запуске.
    /// - Returns: `true`, если запуск приложения следует продолжить.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        return true
    }
}
