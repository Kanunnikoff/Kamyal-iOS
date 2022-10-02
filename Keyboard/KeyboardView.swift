//
//  KeyboardView.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import SwiftUI
import KeyboardKit

struct KeyboardView: View {
    
    @EnvironmentObject private var context: KeyboardContext
    
    let controller: KeyboardInputViewController?
    
    var body: some View {
        VStack(spacing: 0) {
            if context.keyboardType != .emojis {
                MyAutocompleteToolbar()
            }
            
            MyKeyboard(controller: controller)
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(controller: nil)
    }
}
