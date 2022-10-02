//
//  AboutView.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

struct AboutView: View {
    
    @AppStorage("SettingsView.isIngush")
    private var isIngush: Bool = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text(Util.getAppDisplayName())
                    .font(.headline)
                
                Text("\(isIngush ? "Эрш" : "Версия") \(Util.getAppVersion()), сборка \(Util.getAppBuild())")
                    .font(.caption)
                
                Text("© 2022 Дмитрiй Канунниковъ")
                    .font(.subheadline)
                    .padding(.top, 1)
            }
            
            Section {
                Link(destination: Config.APPSTORE_APP_REVIEW_URL) {
                    Text(isIngush ? "Хетар а‌ла" : "Оценить")
                }
                
#if !os(tvOS)
                ShareLink(item: Config.APPSTORE_APP_URL) {
                    Text(isIngush ? "ДӀа-хьа тасса" : "Поделиться")
                }
#endif
                
                Link(destination: Config.APPSTORE_DEVELOPER_URL) {
                    Text(isIngush ? "Кхыйола приложенеш" : "Другие приложения")
                }
                
                Link(destination: Config.APPSTORE_NAZRAN_MOSCOW_URL) {
                    Text(isIngush ? "Приложени «Наьсаре — Москва»" : "Приложение «Назрань — Москва»")
                }
            } header: {
                Text("App Store")
            } footer: {
                Text(isIngush ? "Шоана фу хета ха‌ безам бар са чӀоагӀа. Шоай аьттув бале, хала дале а, оценка а оттайийя, шоашта хетар язде." : "Ваше мнение очень важно для меня. Пожалуйста, не поленитесь поставить оценку и написать отзыв.")
            }
            
            Section {
                Link(destination: Config.EMAIL_URL) {
                    Text(isIngush ? "Каьхат язде" : "Написать письмо")
                }
                
#if !os(watchOS)
                Link(destination: Config.YOUTUBE_URL) {
                    Text(isIngush ? "Са YouTube-канал" : "Мой YouTube-канал")
                }
                
                Link(destination: Config.TWITTER_URL) {
                    Text(isIngush ? "Са Twitter" : "Я в Twitter")
                }
                
                Link(destination: Config.INSTAGRAM_URL) {
                    Text(isIngush ? "Са Instagram" : "Я в Instagram")
                }
#endif
            } header: {
                Text(isIngush ? "Сога хьаязъяр" : "Обратная связь")
            } footer: {
                Text(isIngush ? "Хаттар дале, е вешта áла хӀама дале, юха ца озалуш, хьаязъе!" : "В случае вопросов или предложений, я к Вашим услугам. Будем на связи!")
            }
            
#if !os(watchOS)
            Section {
                Link(destination: Config.PRIVACY_POLICY_URL) {
                    Text(isIngush ? "Деша" : "Читать")
                }
            } header: {
                Text(isIngush ? "Конфиденциальноста политика" : "Политика конфиденциальности")
            } footer: {
                Text(isIngush ? "Хьа дарех приложене пайда мишта эца дувца хоам." : "Подробная информация о том, как приложение использует Ваши данные.")
            }
            
            Section {
                Link(destination: Config.PATREON) {
                    Text("Patreon")
                }
                
                Link(destination: Config.BOOSTY) {
                    Text("Boosty")
                }
            } header: {
                Text(isIngush ? "ОагӀув лаца" : "Поддержка")
            } footer: {
                Text(isIngush ? "Аз хьийга къа зехьа доадаьдац аьнна, шоашта хете, Ӏохьоахадаьча тайпара са оагӀув лаца йиш я хьа." : "Если Вам нравится результат моего труда, то Вы можете, при желании, поддержать меня одним из вышеперечисленных способов.")
            }
#endif
        }
        .navigationTitle(isIngush ? "Программах лаьца" : "О программе")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
