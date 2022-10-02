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
    static let YOUTUBE_URL = URL(string: "https://www.youtube.com/c/DmitryKanunnikoff")!
    static let TWITTER_URL = URL(string: "https://twitter.com/DKanunnikoff")!
    static let INSTAGRAM_URL = URL(string: "https://www.instagram.com/dmitry.kanunnikoff")!
    
    //--- Privacy
    
    static let PRIVACY_POLICY_URL = URL(string: "https://docs.google.com/document/d/1nelj5CzLKdfPF8B50UoeXcKxIADgLeDGJ-04O_wDzow/edit?usp=sharing")!
    
    // --- Support
    
    static let PATREON = URL(string: "https://patreon.com/DmitryKanunnikoff")!
    static let BOOSTY = URL(string: "https://boosty.to/dmitrykanunnikoff")!
    
    // ---
    
    static let APP_GROUP_NAME = "group.software.kanunnikoff.Kamyal"
}
