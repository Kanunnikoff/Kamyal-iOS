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

/// Предоставляет общие операции приложения и сведения из его пакета.
struct Util {

    /// Запрещает создание экземпляров служебного пространства имён.
    private init() {
    }

    /// Копирует строку в системный буфер обмена.
    ///
    /// - Parameter text: Строка, которую требуется скопировать.
    static func copyToClipboard(text: String) {
#if os(iOS)
        UIPasteboard.general.string = text
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#endif
    }

    /// Возвращает внутреннее имя приложения из `Info.plist`.
    ///
    /// - Returns: Значение `CFBundleName` или `nil`, если оно отсутствует.
    static func getAppName() -> String? {
        Bundle.main.infoDictionary?["CFBundleName"] as? String
    }

    /// Возвращает отображаемое имя приложения.
    ///
    /// - Returns: Значение `CFBundleDisplayName`, внутреннее имя либо запасная строка.
    static func getAppDisplayName() -> String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? getAppName() ?? "App Display Name"
    }

    /// Возвращает пользовательскую версию приложения.
    ///
    /// - Returns: Значение `CFBundleShortVersionString` или пустую строку.
    static func getAppVersion() -> String {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return ""
        }
        
        return currentVersion
    }

    /// Возвращает номер сборки приложения.
    ///
    /// - Returns: Значение `CFBundleVersion` или пустую строку.
    static func getAppBuild() -> String {
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let build = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            return ""
            
        }
        
        return build
    }

    /// Определяет имя основного файла значка приложения.
    ///
    /// - Parameter bundle: Пакет, сведения которого требуется прочитать.
    /// - Returns: Имя последнего файла основного значка или `nil`, если описание отсутствует.
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
