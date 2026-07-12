//
//  MainView.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

struct MainView: View {

    private enum Metrics {

        static let cornerRadius: CGFloat = 15
        static let sectionSpacing: CGFloat = 20
    }

    @AppStorage(AppSettingsKey.isIngush)
    private var isIngush: Bool = false

    @AppStorage(
        KeyboardSettingsKey.hasBeenUsed,
        store: UserDefaults(suiteName: Config.APP_GROUP_NAME)
    )
    private var hasUsedKeyboard: Bool = false

    @State private var text = ""

    @StateObject private var tipPurchaseController = TipPurchaseController()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Metrics.sectionSpacing) {
                activationGuide
                keyboardDescription

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
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Къамаьл")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(TipNavigationSubtitleModifier())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    tipPurchaseController.purchase()
                } label: {
                    Image(systemName: "cup.and.heat.waves.fill")
                }
                .disabled(tipPurchaseController.isPurchasing)
                .accessibilityLabel("Оставить чаевые")
            }
        }
        .tips(purchaseController: tipPurchaseController)
        .onAppear {
            Util.requestReviewIfNeeded()
        }
    }
}

private struct TipNavigationSubtitleModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.navigationSubtitle("Спасибо за чаевые!")
        } else {
            content
        }
    }
}

private extension MainView {

    var activationGuide: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 14) {
                ActivationStepView(
                    number: 1,
                    text: isIngush
                        ? "Чоалха оттамашка «Керттердараш» яхача ралса чу вáла (я́ла)."
                        : "Откройте «Настройки» → «Основные»."
                )

                ActivationStepView(
                    number: 2,
                    text: "Клавиатура → Клавиатуры → Новые клавиатуры"
                )

                ActivationStepView(
                    number: 3,
                    text: isIngush
                        ? "Къамаьл яхаш йола лакашка хьалсага."
                        : "Добавьте клавиатуру «Къамаьл».",
                    isCompleted: hasUsedKeyboard
                )

                if !isIngush {
                    Divider()

                    Label(
                        hasUsedKeyboard
                            ? "Клавиатура уже была успешно открыта на этом устройстве."
                            : "В любом обычном поле ввода удерживайте кнопку переключения клавиатур и выберите «Къамаьл».",
                        systemImage: hasUsedKeyboard ? "checkmark.circle.fill" : "globe"
                    )
                    .font(.footnote)
                    .foregroundStyle(hasUsedKeyboard ? Color.green : Color.secondary)

                    Text("В полях пароля и номера телефона iOS показывает системную клавиатуру. Некоторые приложения также могут запрещать сторонние клавиатуры.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label(
                isIngush ? "ГӀалгӀай лакашка хьалсогаргйолаш ер де" : "Как включить клавиатуру",
                systemImage: "keyboard"
            )
        }
    }

    var keyboardDescription: some View {
        VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
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
                cornerRadius: Metrics.cornerRadius,
                style: .continuous
            )
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: Metrics.cornerRadius,
                style: .continuous
            )
        )
    }
}

private struct ActivationStepView: View {

    let number: Int
    let text: String
    var isCompleted = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "\(number).circle.fill")
                .foregroundStyle(isCompleted ? Color.green : Color.accentColor)
                .accessibilityHidden(true)

            Text(text)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
