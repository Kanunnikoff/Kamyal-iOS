//
//  SettingsView.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("SettingsView.isIngush")
    private var isIngush: Bool = false
    
    @AppStorage("SettingsView.Keyboard.isKeyboardLatin", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardLatin: Bool = false
    
    @AppStorage("SettingsView.Keyboard.isKeyboardIngush", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardIngush: Bool = false
    
    @AppStorage("SettingsView.Keyboard.isAudioFeedback", store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardAudioFeedback: Bool = false
    
    var body: some View {
        List {
            Section {
                Toggle(
                    isIngush ? "ГӀалгӀай интерфейс" : "Интерфейс на ингушском",
                    isOn: $isIngush
                )
            } header: {
                Text(isIngush ? "Керттердараш" : "Основные")
            } footer: {
                Text(isIngush ? "Приложене чу мел дола йоазув гӀалгӀай меттала Ӏооттаду." : "Возможность отображения текста на ингушском языке.")
            }
            
            Section {
                Toggle(
                    isIngush ? "Латиний йоазонцара алапат" : "Алфавит на основе латиницы",
                    isOn: $isKeyboardLatin
                )
                
                Toggle(
                    isIngush ? "ГӀалгӀай интерфейс" : "Интерфейс на ингушском",
                    isOn: $isKeyboardIngush
                )
                
                Toggle(
                    isIngush ? "Лакий оаз" : "Звуковой сигнал клавиш",
                    isOn: $isKeyboardAudioFeedback
                )
            } header: {
                Text(isIngush ? "Лакашка" : "Клавиатура")
            } footer: {
                Text(isIngush ? "Латиний йоазонцара дола алапат хьагойта йиш хилари, лакаш теӀаеча хана оаз ялийтари." : "Возможность включения латинского алфавита и отображения текста на ингушском языке. Ну, и звук при нажатии клавиш.")
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#elseif !os(tvOS) && !os(watchOS)
        .listStyle(.inset)
#endif
        .navigationTitle(isIngush ? "Оттамаш" : "Настройки")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
