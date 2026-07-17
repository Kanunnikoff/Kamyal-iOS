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

struct Util {

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

    static func getAppIconName(in bundle: Bundle = .main) -> String? {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last else {
            return nil
        }

        return iconFileName
    }
    
}
