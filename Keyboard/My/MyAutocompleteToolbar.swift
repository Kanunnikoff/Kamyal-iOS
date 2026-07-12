//
//  MyAutocompleteToolbar.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit

enum MyAutocompleteToolbar {

    private static let height: CGFloat = 50

    static var style: AutocompleteToolbarStyle {
        var style = AutocompleteToolbarStyle.standard
        style.height = height
        return style
    }
}
