//
//  MyKeyboard.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit
import SwiftUI

struct MyKeyboard: View {

    @AppStorage(
        KeyboardSettingsKey.isKeyboardLatin,
        store: UserDefaults(suiteName: Config.APP_GROUP_NAME)
    )
    private var isKeyboardLatin = false

    private let services: KeyboardServices

    @ObservedObject private var keyboardContext: KeyboardContext

    init(
        services: KeyboardServices,
        state: KeyboardState
    ) {
        self.services = services
        _keyboardContext = ObservedObject(wrappedValue: state.keyboardContext)
    }

    var body: some View {
        KeyboardKit.KeyboardView(
            layout: keyboardLayout,
            services: services,
            buttonContent: { parameters in
                MyKeyboardButtonContent(
                    action: parameters.item.action,
                    standardContent: parameters.view
                )
            },
            buttonView: { parameters in
                parameters.view
            },
            collapsedView: { parameters in
                parameters.view
            },
            emojiKeyboard: { _ in
                MyEmojiKeyboard(services: services)
            },
            toolbar: { parameters in
                parameters.view
            }
        )
        .keyboardCalloutActions { parameters in
            customCalloutActions(for: parameters.action) ?? parameters.standardActions()
        }
        .autocompleteToolbarStyle(MyAutocompleteToolbar.style)
        .environment(\.layoutDirection, .leftToRight)
    }
}

private extension MyKeyboard {

    var keyboardLayout: KeyboardLayout {
        // Базовый построитель KeyboardKit сохраняет служебные клавиши и переходы
        // между буквенным, цифровым и символьным режимами, а мы заменяем только ряды ввода.
        if isKeyboardLatin {
            let inputSets = LatinIngushInputSetProvider()

            let baseLayout = KeyboardLayout(
                baseLayoutFor: keyboardContext,
                alphabeticInputSet: inputSets.alphabeticInputSet,
                numericInputSet: inputSets.numericInputSet,
                symbolicInputSet: inputSets.symbolicInputSet
            )

            return deviceLayout(from: baseLayout)
        }

        let inputSets = IngushInputSetProvider()

        let baseLayout = KeyboardLayout(
            baseLayoutFor: keyboardContext,
            alphabeticInputSet: inputSets.alphabeticInputSet,
            numericInputSet: inputSets.numericInputSet,
            symbolicInputSet: inputSets.symbolicInputSet
        )

        return deviceLayout(from: baseLayout)
    }

    func deviceLayout(from baseLayout: KeyboardLayout) -> KeyboardLayout {
        // На iPad библиотека добавляет отдельные служебные ряды и размеры клавиш,
        // а плавающая клавиатура сообщает тип iPhone через deviceTypeForKeyboard.
        if keyboardContext.deviceTypeForKeyboard.isPad {
            return baseLayout.iPadLayout(for: keyboardContext)
        }

        return baseLayout.iPhoneLayout(for: keyboardContext)
    }

    func customCalloutActions(for action: KeyboardAction) -> [KeyboardAction]? {
        if isKeyboardLatin {
            return LatinIngushCalloutActionProvider().calloutActions(for: action)
        }

        return IngushCalloutActionProvider().calloutActions(for: action)
    }
}

private struct MyKeyboardButtonContent<StandardContent: View>: View {

    @AppStorage(
        KeyboardSettingsKey.isKeyboardLatin,
        store: UserDefaults(suiteName: Config.APP_GROUP_NAME)
    )
    private var isKeyboardLatin = false

    @AppStorage(
        KeyboardSettingsKey.isKeyboardIngush,
        store: UserDefaults(suiteName: Config.APP_GROUP_NAME)
    )
    private var isKeyboardIngush = false

    let action: KeyboardAction
    let standardContent: StandardContent

    @ViewBuilder
    var body: some View {
        if let title = MyKeyboardAppearance.buttonTitle(
            for: action,
            isKeyboardLatin: isKeyboardLatin,
            isKeyboardIngush: isKeyboardIngush
        ) {
            Keyboard.ButtonTitle(
                text: title,
                action: action
            )
        } else {
            standardContent
        }
    }
}

enum KeyboardSettingsKey {

    static let isAudioFeedback = "SettingsView.Keyboard.isAudioFeedback"
    static let isKeyboardIngush = "SettingsView.Keyboard.isKeyboardIngush"
    static let isKeyboardLatin = "SettingsView.Keyboard.isKeyboardLatin"
}

private struct MyEmojiKeyboard: View {

    private enum Metrics {

        static let bottomBarHeight: CGFloat = 44
        static let categoryButtonSize: CGFloat = 36
        static let emojiFontSize: CGFloat = 32
        static let emojiItemHeight: CGFloat = 42
        static let emojiItemWidth: CGFloat = 44
        static let horizontalPadding: CGFloat = 6
        static let rowCount = 4
        static let rowSpacing: CGFloat = 2
    }

    private let services: KeyboardServices

    @State private var selectedCategory: EmojiCategory = .smileysAndPeople

    init(services: KeyboardServices) {
        self.services = services
    }

    var body: some View {
        VStack(spacing: 0) {
            emojiGrid
            bottomBar
        }
    }
}

private extension MyEmojiKeyboard {

    var categories: [EmojiCategory] {
        let recentCategory = EmojiCategory.recent
        if recentCategory.hasEmojis {
            return [recentCategory] + EmojiCategory.standardCategories
        }

        return EmojiCategory.standardCategories
    }

    var emojiRows: [GridItem] {
        Array(
            repeating: GridItem(
                .fixed(Metrics.emojiItemHeight),
                spacing: Metrics.rowSpacing
            ),
            count: Metrics.rowCount
        )
    }

    var emojiGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(
                rows: emojiRows,
                spacing: Metrics.rowSpacing
            ) {
                ForEach(selectedCategory.emojis) { emoji in
                    Button {
                        insert(emoji)
                    } label: {
                        Text(emoji.char)
                            .font(.system(size: Metrics.emojiFontSize))
                            .frame(
                                width: Metrics.emojiItemWidth,
                                height: Metrics.emojiItemHeight
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(emoji.localizedName)
                }
            }
            .padding(.horizontal, Metrics.horizontalPadding)
        }
    }

    var bottomBar: some View {
        HStack(spacing: 0) {
            Button("АБВ") {
                services.actionHandler.handle(.keyboardType(.alphabetic))
            }
            .frame(width: Metrics.categoryButtonSize)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            category.symbolIcon
                                .frame(
                                    width: Metrics.categoryButtonSize,
                                    height: Metrics.categoryButtonSize
                                )
                                .background(
                                    selectedCategory == category
                                        ? Color.primary.opacity(0.12)
                                        : Color.clear
                                )
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(category.labelText(for: .russian))
                    }
                }
            }

            Button {
                services.actionHandler.handle(.nextKeyboard)
            } label: {
                Image(systemName: "globe")
            }
            .frame(width: Metrics.categoryButtonSize)
            .accessibilityLabel("Следующая клавиатура")

            Button {
                services.actionHandler.handle(.backspace)
            } label: {
                Image(systemName: "delete.left")
            }
            .frame(width: Metrics.categoryButtonSize)
            .accessibilityLabel("Удалить")
        }
        .buttonStyle(.plain)
        .frame(height: Metrics.bottomBarHeight)
        .padding(.horizontal, Metrics.horizontalPadding)
    }

    func insert(_ emoji: Emoji) {
        EmojiCategory.Persisted.recent.addEmoji(emoji)
        services.actionHandler.handle(.emoji(emoji))
    }
}
