//
//  Config.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import Foundation
import SwiftUI

/// Общие параметры приложения и адреса связанных ресурсов.
struct Config {

    // MARK: - Режим проверки

    static let isTestMode = false

    // MARK: - App Store

    static let APPSTORE_APP_ID = 6443646651
    static let APPSTORE_APP_URL = URL(string: "https://itunes.apple.com/app/id\(APPSTORE_APP_ID)")!
    static let APPSTORE_APP_REVIEW_URL = URL(string: "https://itunes.apple.com/app/id\(APPSTORE_APP_ID)?action=write-review")!
    static let APPSTORE_DEVELOPER_URL = URL(string: "https://itunes.apple.com/developer/id1449411291")!
    static let APPSTORE_NAZRAN_MOSCOW_URL = URL(string: "https://itunes.apple.com/app/id1449411292")!
    static let REQUEST_REVIEW_LAUNCHES_COUNT_THRESHOLD = 5

    static let PACKAGE_NAME = "software.kanunnikoff.Kamyal"

    // MARK: - Обратная связь

    static let EMAIL_URL = URL(string: "mailto:dmitry.kanunnikoff@gmail.com?subject=%D0%9A%D1%8A%D0%B0%D0%BC%D0%B0%D1%8C%D0%BB%20%28iOS%29")!

    // MARK: - Конфиденциальность

    static let PRIVACY_POLICY_URL = URL(string: "https://docs.google.com/document/d/1nelj5CzLKdfPF8B50UoeXcKxIADgLeDGJ-04O_wDzow/edit?usp=sharing")!

    // MARK: - Общая группа

    static let APP_GROUP_NAME = "group.software.kanunnikoff.Kamyal"
}

/// Ключи настроек, принадлежащих основному приложению.
enum AppSettingsKey {

    static let isIngush = "SettingsView.isIngush"
}

/// Ключи настроек клавиатуры в общей группе приложения и расширения.
enum KeyboardSettingsKey {

    static let hasBeenUsed = "Keyboard.hasBeenUsed"
    static let isAutocapitalizationEnabled = "SettingsView.Keyboard.isAutocapitalizationEnabled"
    static let isAudioFeedback = "SettingsView.Keyboard.isAudioFeedback"
    static let isKeyboardIngush = "SettingsView.Keyboard.isKeyboardIngush"
    static let isKeyboardLatin = "SettingsView.Keyboard.isKeyboardLatin"
}
