//
//  MyAutocompleteToolbar.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//


import KeyboardKit
import SwiftUI

struct MyAutocompleteToolbar: View {
    
    @EnvironmentObject private var context: AutocompleteContext
    @EnvironmentObject private var keyboardContext: KeyboardContext
    
    var body: some View {
        AutocompleteToolbar(
            suggestions: context.suggestions,
            locale: keyboardContext.locale
        )
        .frame(height: 50)
    }
}

private extension MyAutocompleteToolbar {
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

struct MyAutocompleteToolbar_Previews: PreviewProvider {
    
    static var previews: some View {
        MyAutocompleteToolbar()
    }
}
