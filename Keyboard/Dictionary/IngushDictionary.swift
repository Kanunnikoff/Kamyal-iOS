//
//  IngushDictionary.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation
import SwiftUI

class IngushDictionary {
    
    @AppStorage("SettingsView.Keyboard.isKeyboardLatin", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardLatin: Bool = false
    
    var words = [String]()
    
    init() {
        if !isKeyboardLatin {
            BG {
                let path = Bundle.main.path(forResource: "ing_freq_dict_sorted", ofType: "csv")
                
                if let path = path, let fileContent = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) {
                    self.words = fileContent.components(separatedBy: .newlines)
                        .compactMap { $0.split(separator: ";").first }
                        .map { String($0) }
                    
#if DEBUG
                    print("*- words count: \(self.words.count)")
#endif
                }
            }
        }
    }
}
