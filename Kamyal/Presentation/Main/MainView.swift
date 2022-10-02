//
//  MainView.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("SettingsView.isIngush")
    private var isIngush: Bool = false
    
    @State private var text = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    Text(isIngush ? "ГӀалгӀай лакашка хьалсогаргйолаш ер де:\n• Чоалха оттамашка «Керттердараш» яхача ралса чу вáла (я́ла), цигара —> Клавиатура -> Клавиатуры -> Новые клавиатуры\n• Къамаьл яхаш йола лакашка хьалсага." : "Для включения ингушской клавиатуры выполните ​следующие​ шаги:\n• в Настройках устройства зайдите в раздел Основные -> Клавиатура -> Клавиатуры -> ​Новые​ клавиатуры\n• включите клавиатуру с названием Къамаьл")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                    
                    Text(isIngush ? "Лакашка чу деррига гӀалгӀай алапаш долаш да: кириллица тӀа оттадаьраш а, 1938-ча шерага кхаччалца леладаь латиница тӀа оттадаь хиннараш а." : "Клавиатура содержит ​все буквы ингушского алфавита: как на основе кириллицы, так и на основе латиницы, применявшейся до 1938-го года.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                    
                    Text(isIngush ? "​Цхьадола алапаш тара долча алапашта тӀа пӀелг ӀотӀатоӀабаь лоаттабича, хьаувтт." : "Некоторые буквы доступны по долгому удержанию соответствующих букв со схожим начертанием.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .continuous
                    )
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .continuous
                    )
                )
                
                TextField(isIngush ? "Чуяздаьр нийса дий хьажа" : "Проверьте ввод", text: $text, axis: .vertical)
                    .lineLimit(...5)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.sentences)
                    .font(.body)
#if os(iOS)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
#endif
                
                Spacer()
            }
            .padding()
            .navigationTitle("Къамаьл")
            .onAppear {
                Util.requestReviewIfNeeded()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
