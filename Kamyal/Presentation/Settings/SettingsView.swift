//
//  SettingsView.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

/// Позволяет настроить язык приложения и поведение клавиатуры.
struct SettingsView: View {
    
    @AppStorage(AppSettingsKey.isIngush)
    private var isIngush: Bool = false
    
    @AppStorage(KeyboardSettingsKey.isKeyboardLatin, store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardLatin: Bool = false
    
    @AppStorage(KeyboardSettingsKey.isKeyboardIngush, store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardIngush: Bool = false
    
    @AppStorage(KeyboardSettingsKey.isAudioFeedback, store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardAudioFeedback: Bool = false

    @AppStorage(KeyboardSettingsKey.isAutocapitalizationEnabled, store: UserDefaults(suiteName: Config.APP_GROUP_NAME))
    private var isKeyboardAutocapitalizationEnabled: Bool = true
    
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

                Toggle(
                    "Заглавная буква в начале предложения",
                    isOn: $isKeyboardAutocapitalizationEnabled
                )
            } header: {
                Text(isIngush ? "Лакашка" : "Клавиатура")
            } footer: {
                Text(isIngush ? "Латиний йоазонцара дола алапат хьагойта йиш хилари, лакаш теӀаеча хана оаз ялийтари." : "Настройки алфавита, подписей клавиш, автоматической заглавной буквы и звука при нажатии.")
            }
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#elseif !os(tvOS) && !os(watchOS)
        .listStyle(.inset)
#endif
        .navigationTitle(isIngush ? "Оттамаш" : "Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Предварительный просмотр экрана настроек.
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
