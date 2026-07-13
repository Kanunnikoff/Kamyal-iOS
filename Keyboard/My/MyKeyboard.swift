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
        .overlay(alignment: .top) {
            if keyboardContext.keyboardType.isAlphabetic {
                MyAutocompleteToolbar.separators
            }
        }
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

        return systemIngushLayout(
            from: baseLayout.iPhoneLayout(for: keyboardContext)
        )
    }

    func systemIngushLayout(from layout: KeyboardLayout) -> KeyboardLayout {
        var result = layout

        // Все режимы используют одну внешнюю ширину. Без этой поправки цифровая
        // и символьная раскладки занимают ещё по 10 физических пикселей с каждой
        // стороны, поэтому клавиши заметно разъезжаются при переключении.
        result.configuration.edgeInsets.leading += AlphabeticLayoutMetrics.horizontalKeyboardInset
        result.configuration.edgeInsets.trailing += AlphabeticLayoutMetrics.horizontalKeyboardInset

        if result.itemRows.indices.contains(AlphabeticLayoutMetrics.serviceRowIndex) {
            // KeyboardKit располагает служебный ряд немного выше системного и делает
            // его на 15 физических пикселей ниже по высоте. Несимметричная поправка
            // внутренних отступов одновременно сдвигает ряд вниз на нужные 10 пикселей
            // сверху и увеличивает клавиши до системной нижней границы ещё на 15 пикселей.
            result.itemRows[AlphabeticLayoutMetrics.serviceRowIndex] = result.itemRows[
                AlphabeticLayoutMetrics.serviceRowIndex
            ].map { item in
                var item = item
                item.edgeInsets.top += AlphabeticLayoutMetrics.serviceRowTopInsetIncrease
                item.edgeInsets.bottom -= AlphabeticLayoutMetrics.serviceRowBottomInsetDecrease

                return item
            }
        }

        guard keyboardContext.keyboardType.isAlphabetic, !isKeyboardLatin else {
            for rowIndex in result.itemRows.indices.prefix(AlphabeticLayoutMetrics.rowCount) {
                result.itemRows[rowIndex] = result.itemRows[rowIndex].map {
                    verticallyAlignedInputItem(from: $0)
                }
            }

            return result
        }

        for rowIndex in result.itemRows.indices.prefix(AlphabeticLayoutMetrics.rowCount) {
            let row = result.itemRows[rowIndex]
            let visibleItems = row.filter { !$0.action.isCharacterMargin }

            guard visibleItems.count == AlphabeticLayoutMetrics.columnCount else {
                continue
            }

            // Стандартная русская основа KeyboardKit рассчитана на 12 букв в верхнем
            // ряду и может добавлять невидимые поля по краям. В системной ингушской
            // раскладке каждый из трёх рядов занимает ровно 11 равных ячеек. Поэтому
            // удаляем служебные поля, задаём общий внешний отступ в конфигурации и
            // поровну распределяем доступную ширину между всеми видимыми клавишами.
            let resizedItems = visibleItems.map { item in
                var item = verticallyAlignedInputItem(from: item)
                item.size.width = AlphabeticLayoutMetrics.itemWidth

                return item
            }

            result.itemRows[rowIndex] = resizedItems
        }

        return result
    }

    func verticallyAlignedInputItem(
        from layoutItem: KeyboardLayoutItem
    ) -> KeyboardLayoutItem {
        var item = layoutItem

        // Одинаковая поправка для буквенного, цифрового и символьного режимов
        // исключает вертикальный скачок при переключении. На экране @3x верхняя
        // граница опускается на 10 пикселей, а нижняя — на 4 пикселя, поэтому
        // положение и высота клавиш совпадают с системной ингушской раскладкой.
        item.edgeInsets.top += AlphabeticLayoutMetrics.inputRowTopInsetIncrease
        item.edgeInsets.bottom -= AlphabeticLayoutMetrics.inputRowBottomInsetDecrease

        return item
    }

    func customCalloutActions(for action: KeyboardAction) -> [KeyboardAction]? {
        if isKeyboardLatin {
            return LatinIngushCalloutActionProvider().calloutActions(for: action)
        }

        return IngushCalloutActionProvider().calloutActions(for: action)
    }
}

private enum AlphabeticLayoutMetrics {

    static let columnCount = 11
    static let rowCount = 3

    // Эти отступы компенсируют геометрию основы KeyboardKit: на экране @3x
    // верхняя граница опускается на 10 пикселей, а нижняя — на 4 пикселя.
    static let inputRowBottomInsetDecrease: CGFloat = 4 / 3
    static let inputRowTopInsetIncrease: CGFloat = 10 / 3

    // 3,5 пункта по краям всей раскладки дают те же ширину ячеек
    // и внешние поля, что у системной ингушской клавиатуры.
    static let horizontalKeyboardInset: CGFloat = 3.5
    static let serviceRowBottomInsetDecrease: CGFloat = 5
    static let serviceRowIndex = 3
    static let serviceRowTopInsetIncrease: CGFloat = 10 / 3

    static var itemWidth: KeyboardLayoutItem.Width {
        .percentage(1 / CGFloat(columnCount))
    }
}

private extension KeyboardAction {

    var isCharacterMargin: Bool {
        if case .characterMargin = self {
            return true
        }

        return false
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
