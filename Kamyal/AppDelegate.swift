//
//  AppDelegate.swift
//  Kamyal
//
//  Created by Codex on 20.07.2026.
//

import FirebaseCore
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

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
