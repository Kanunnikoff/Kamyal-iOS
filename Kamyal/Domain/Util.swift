//
//  Util.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import StoreKit

struct Util {
    
    private static let LAUNCHES_COUNT_THRESHOLD = 5
    
    @AppStorage("Util.launchesCount")
    private static var launchesCount: Int = 0
    
    @AppStorage("Util.lastVersionPromtedForReview")
    private static var lastVersionPromtedForReview: String = ""
    
    @Environment(\.requestReview) static var requestReview
    
    private init() {
    }
    
    static func copyToClipboard(text: String) {
#if os(iOS)
        UIPasteboard.general.string = text
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#endif
    }
    
    static func getAppName() -> String? {
        Bundle.main.infoDictionary?["CFBundleName"] as? String
    }
    
    static func getAppDisplayName() -> String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? getAppName() ?? "App Display Name"
    }
    
    static func getAppVersion() -> String {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        
        return currentVersion
    }
    
    static func getAppBuild() -> String {
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let build = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            return ""
            
        }
        
        return build
    }
    
    @MainActor static func requestReviewIfNeeded() {
        launchesCount += 1
        
        // Get the current bundle version for the app
        let currentVersion = getAppBuild()
        
        // Has the process been completed several times and the user has not already been prompted for this version?
        if launchesCount >= LAUNCHES_COUNT_THRESHOLD && currentVersion != lastVersionPromtedForReview {
            requestReview()
            lastVersionPromtedForReview = currentVersion
        }
    }
}
