//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import UIKit
import KeyboardKit
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {
    
    @AppStorage("SettingsView.Keyboard.isKeyboardLatin", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardLatin: Bool = false
    
    override func viewDidLoad() {
        keyboardContext.locale = KeyboardLocale.russian.locale
        keyboardAppearance = MyKeyboardAppearance(context: keyboardContext)
        
        var vaynakhCalloutActionProvider: LocalizedCalloutActionProvider {
            if isKeyboardLatin {
                guard let provider = try? LatinVaynakhCalloutActionProvider() else {
                    fatalError("LatinVaynakhCalloutActionProvider could not be created.")
                }
                
                return provider
            } else {
                guard let provider = try? VaynakhCalloutActionProvider() else {
                    fatalError("VaynakhCalloutActionProvider could not be created.")
                }
                
                return provider
            }
        }
        
        calloutActionProvider = StandardCalloutActionProvider(
            context: keyboardContext,
            providers: [vaynakhCalloutActionProvider]
        )
        
        if isKeyboardLatin {
            inputSetProvider = StandardInputSetProvider(
                context: keyboardContext,
                providers: [LatinVaynakhInputSetProvider()]
            )
        } else {
            inputSetProvider = StandardInputSetProvider(
                context: keyboardContext,
                providers: [VaynakhInputSetProvider()]
            )
        }
        
        keyboardLayoutProvider = StandardKeyboardLayoutProvider(inputSetProvider: inputSetProvider)
        
        keyboardActionHandler = MyKeyboardActionHandler(inputViewController: self)
        
        super.viewDidLoad()
    }
    
    override func viewWillSetupKeyboard() {
        super.viewWillSetupKeyboard()
        
        setup(with: KeyboardView(controller: self))
    }

}
