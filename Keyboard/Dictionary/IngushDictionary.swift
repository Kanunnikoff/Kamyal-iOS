//
//  IngushDictionary.swift
//  Keyboard
//
//  Created by Дмитрiй Канунниковъ on 04.10.2022.
//

import Foundation

class IngushDictionary {
    
    var words = [String]()
    
    init() {
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
