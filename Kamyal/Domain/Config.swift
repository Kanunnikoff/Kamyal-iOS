//
//  Config.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import Foundation
import SwiftUI

struct Config {
    
    //--- Test
    
    static let isTestMode = false
    
    //--- App Store
    
    static let APPSTORE_APP_ID = 6443646651
    static let APPSTORE_APP_URL = URL(string: "https://itunes.apple.com/app/id\(APPSTORE_APP_ID)")!
    static let APPSTORE_APP_REVIEW_URL = URL(string: "https://itunes.apple.com/app/id\(APPSTORE_APP_ID)?action=write-review")!
    static let APPSTORE_DEVELOPER_URL = URL(string: "https://itunes.apple.com/developer/id1449411291")!
    static let APPSTORE_NAZRAN_MOSCOW_URL = URL(string: "https://itunes.apple.com/app/id1449411292")!
    
    static let PACKAGE_NAME = "software.kanunnikoff.Kamyal"
    
    //--- Feedback
    
    static let EMAIL_URL = URL(string: "mailto:dmitry.kanunnikoff@gmail.com?subject=%D0%9A%D1%8A%D0%B0%D0%BC%D0%B0%D1%8C%D0%BB%20%28iOS%29")!
    
    //--- Privacy
    
    static let PRIVACY_POLICY_URL = URL(string: "https://docs.google.com/document/d/1nelj5CzLKdfPF8B50UoeXcKxIADgLeDGJ-04O_wDzow/edit?usp=sharing")!
    
    // ---
    
    static let APP_GROUP_NAME = "group.software.kanunnikoff.Kamyal"
}

enum AppSettingsKey {

    static let isIngush = "SettingsView.isIngush"
}

enum KeyboardSettingsKey {

    static let hasBeenUsed = "Keyboard.hasBeenUsed"
    static let isAudioFeedback = "SettingsView.Keyboard.isAudioFeedback"
    static let isKeyboardIngush = "SettingsView.Keyboard.isKeyboardIngush"
    static let isKeyboardLatin = "SettingsView.Keyboard.isKeyboardLatin"
}
