//
//  MyKeyboard.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit
import SwiftUI

/// Собирает раскладку, оформление клавиш и панель эмодзи для расширения.
struct MyKeyboard: View {

    @AppStorage(
        KeyboardSettingsKey.isKeyboardLatin,
        store: UserDefaults(suiteName: Config.APP_GROUP_NAME)
    )
    private var isKeyboardLatin = false

    private let services: KeyboardServices

    @ObservedObject private var keyboardContext: KeyboardContext

    /// Создаёт клавиатуру с переданными службами и общим состоянием KeyboardKit.
    ///
    /// - Parameters:
    ///   - services: Службы обработки действий и подсказок.
    ///   - state: Наблюдаемое состояние расширения клавиатуры.
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
                    keyboardContext: keyboardContext,
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
                MyEmojiKeyboard(
                    services: services,
                    isPadKeyboard: isPadKeyboard
                )
            },
            toolbar: { parameters in
                parameters.view
            }
        )
        .keyboardCalloutActions { parameters in
            customCalloutActions(for: parameters.action) ?? parameters.standardActions()
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

private extension MyKeyboard {

    var isPadKeyboard: Bool {
        keyboardContext.deviceTypeForKeyboard.isPad
    }

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

    /// Преобразует базовую раскладку для фактического вида клавиатуры устройства.
    ///
    /// - Parameter baseLayout: Раскладка, построенная KeyboardKit из наборов символов.
    /// - Returns: Раскладка с геометрией iPhone или iPad.
    func deviceLayout(from baseLayout: KeyboardLayout) -> KeyboardLayout {
        // На iPad библиотека добавляет отдельные служебные ряды и размеры клавиш,
        // а плавающая клавиатура сообщает тип iPhone через deviceTypeForKeyboard.
        if isPadKeyboard {
            return systemPadLayout(
                from: baseLayout.iPadLayout(for: keyboardContext)
            )
        }

        return systemIngushLayout(
            from: baseLayout.iPhoneLayout(for: keyboardContext)
        )
    }

    /// Приближает геометрию раскладки iPhone к системной ингушской клавиатуре.
    ///
    /// - Parameter layout: Раскладка iPhone от KeyboardKit.
    /// - Returns: Раскладка с согласованными размерами и отступами рядов.
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

    /// Приближает размеры буквенных и служебных клавиш iPad к системным.
    ///
    /// - Parameter layout: Раскладка iPad от KeyboardKit.
    /// - Returns: Раскладка с перераспределённой шириной клавиш.
    func systemPadLayout(from layout: KeyboardLayout) -> KeyboardLayout {
        var result = layout

        guard result.itemRows.indices.contains(PadLayoutMetrics.topRowIndex),
              result.itemRows.indices.contains(PadLayoutMetrics.middleRowIndex),
              result.itemRows.indices.contains(PadLayoutMetrics.lowerRowIndex) else {
            return result
        }

        // Системная клавиатура iPad сохраняет одинаковую ширину клавиш ввода
        // во всех рядах, а свободное место отдаёт служебным клавишам. Стандартная
        // схема KeyboardKit делает удаление и «Ввод» обычными клавишами ввода,
        // поэтому клавиша удаления сжимается, а ширина букв и знаков зависит
        // от выбранного режима.
        result.itemRows[PadLayoutMetrics.topRowIndex] = padTopRow(
            from: result.itemRows[PadLayoutMetrics.topRowIndex]
        )
        result.itemRows[PadLayoutMetrics.middleRowIndex] = padMiddleRow(
            from: result.itemRows[PadLayoutMetrics.middleRowIndex]
        )
        result.itemRows[PadLayoutMetrics.lowerRowIndex] = padLowerRow(
            from: result.itemRows[PadLayoutMetrics.lowerRowIndex]
        )

        if result.itemRows.indices.contains(PadLayoutMetrics.serviceRowIndex) {
            result.itemRows[PadLayoutMetrics.serviceRowIndex] = padServiceRow(
                from: result.itemRows[PadLayoutMetrics.serviceRowIndex]
            )
        }

        return result
    }

    /// Настраивает ширину клавиш верхнего ряда iPad.
    ///
    /// - Parameter row: Исходный верхний ряд.
    /// - Returns: Ряд с расширенной завершающей служебной клавишей.
    func padTopRow(from row: KeyboardLayoutItemRow) -> KeyboardLayoutItemRow {
        guard row.count >= PadLayoutMetrics.minimumInputRowItemCount else {
            return row
        }

        return row.enumerated().map { index, sourceItem in
            var item = sourceItem
            let isTrailingItem = index == row.index(before: row.endIndex)
            item.size.width = isTrailingItem
                ? PadLayoutMetrics.topRowTrailingItemWidth
                : .input

            return item
        }
    }

    /// Настраивает ширину клавиш среднего ряда iPad.
    ///
    /// - Parameter row: Исходный средний ряд.
    /// - Returns: Ряд с фиксированной начальной и доступной завершающей шириной.
    func padMiddleRow(from row: KeyboardLayoutItemRow) -> KeyboardLayoutItemRow {
        guard row.count >= PadLayoutMetrics.minimumInputRowItemCount else {
            return row
        }

        return row.enumerated().map { index, sourceItem in
            var item = sourceItem

            if index == row.startIndex {
                item.size.width = PadLayoutMetrics.middleRowLeadingItemWidth
            } else if index == row.index(before: row.endIndex) {
                item.size.width = .available
            } else {
                item.size.width = .input
            }

            return item
        }
    }

    /// Настраивает ширину клавиш нижнего буквенного ряда iPad.
    ///
    /// - Parameter row: Исходный нижний ряд.
    /// - Returns: Ряд с растягиваемыми служебными клавишами по краям.
    func padLowerRow(from row: KeyboardLayoutItemRow) -> KeyboardLayoutItemRow {
        guard row.count >= PadLayoutMetrics.minimumInputRowItemCount else {
            return row
        }

        return row.enumerated().map { index, sourceItem in
            var item = sourceItem
            let isServiceItem = index == row.startIndex
                || index == row.index(before: row.endIndex)
            item.size.width = isServiceItem ? .available : .input

            return item
        }
    }

    /// Применяет системные пропорции к служебному ряду iPad.
    ///
    /// - Parameter row: Исходный служебный ряд.
    /// - Returns: Ряд с заданными долями ширины либо исходный ряд неожиданного состава.
    func padServiceRow(from row: KeyboardLayoutItemRow) -> KeyboardLayoutItemRow {
        guard row.count == PadLayoutMetrics.serviceRowWidths.count else {
            return row
        }

        return zip(row, PadLayoutMetrics.serviceRowWidths).map { sourceItem, width in
            var item = sourceItem
            item.size.width = width

            return item
        }
    }

    /// Корректирует вертикальные отступы одной клавиши ввода на iPhone.
    ///
    /// - Parameter layoutItem: Исходная клавиша раскладки.
    /// - Returns: Клавиша с границами, согласованными с системной раскладкой.
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

    /// Возвращает пользовательские варианты долгого нажатия для текущего алфавита.
    ///
    /// - Parameter action: Действие нажатой клавиши.
    /// - Returns: Варианты символов либо `nil`, если они не определены.
    func customCalloutActions(for action: KeyboardAction) -> [KeyboardAction]? {
        if isKeyboardLatin {
            return LatinIngushCalloutActionProvider().calloutActions(for: action)
        }

        return IngushCalloutActionProvider().calloutActions(for: action)
    }
}

/// Геометрические параметры буквенной раскладки iPhone.
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

/// Геометрические параметры полноразмерной раскладки iPad.
private enum PadLayoutMetrics {

    static let lowerRowIndex = 2
    static let middleRowIndex = 1
    static let minimumInputRowItemCount = 3
    static let serviceRowIndex = 3
    static let topRowIndex = 0

    // Доли получены по системной клавиатуре iPad Pro 11″ в альбомной
    // ориентации. Они сохраняют взаимные пропорции и в книжной ориентации,
    // поскольку KeyboardKit рассчитывает их от доступной ширины ряда.
    static let middleRowLeadingItemWidth: KeyboardLayoutItem.Width = .percentage(0.09)
    static let topRowTrailingItemWidth: KeyboardLayoutItem.Width = .percentage(0.13)

    static let serviceRowWidths: [KeyboardLayoutItem.Width] = [
        .percentage(0.08),
        .percentage(0.08),
        .percentage(0.08),
        .percentage(0.532),
        .percentage(0.114),
        .percentage(0.114)
    ]
}

private extension KeyboardAction {

    var isCharacterMargin: Bool {
        if case .characterMargin = self {
            return true
        }

        return false
    }
}

/// Подменяет подписи отдельных служебных клавиш, сохраняя стандартное содержимое остальных.
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
    let keyboardContext: KeyboardContext
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
            // Стандартное содержимое KeyboardKit добавляет зависящие от действия
            // и устройства внутренние отступы. При замене всего содержимого на наш
            // заголовок эта обёртка исчезает, из-за чего подпись «Ввод» на iPad
            // прижимается к нижнему правому краю. Возвращаем те же отступы явно.
            .padding(action.standardButtonContentInsets(for: keyboardContext))
        } else {
            standardContent
        }
    }
}

/// Пользовательская панель эмодзи для компактной и полноразмерной клавиатуры.
private struct MyEmojiKeyboard: View {

    /// Геометрические параметры панели эмодзи на iPhone и плавающем iPad.
    private enum CompactMetrics {

        static let bottomBarHeight: CGFloat = 44
        static let categoryButtonSize: CGFloat = 36
        static let emojiFontSize: CGFloat = 32
        static let emojiItemHeight: CGFloat = 42
        static let emojiItemWidth: CGFloat = 44
        static let horizontalPadding: CGFloat = 6
        static let rowCount = 4
        static let rowSpacing: CGFloat = 2
    }

    /// Геометрические параметры полноразмерной панели эмодзи на iPad.
    private enum PadMetrics {

        static let bottomBarHeight: CGFloat = 44
        static let categoryButtonSize: CGFloat = 36
        static let columnSpacing: CGFloat = 10
        static let emojiFontSize: CGFloat = 40
        static let emojiItemHeight: CGFloat = 55
        static let emojiItemWidth: CGFloat = 55
        static let horizontalPadding: CGFloat = 20
        static let maximumRowCount = 6
        static let minimumRowCount = 4
        static let rowSpacing: CGFloat = 8
        static let sectionSpacing: CGFloat = 32
        static let sectionTitleBottomSpacing: CGFloat = 10
        static let sectionTitleFontSize: CGFloat = 13
        static let sectionTitleHeight: CGFloat = 16
        static let topPadding: CGFloat = 12
    }

    private let isPadKeyboard: Bool
    private let services: KeyboardServices

    @State private var selectedCategory: EmojiCategory = .smileysAndPeople

    /// Создаёт панель эмодзи и выбирает начальную категорию.
    ///
    /// - Parameters:
    ///   - services: Службы KeyboardKit для вставки символов и служебных действий.
    ///   - isPadKeyboard: Признак полноразмерной клавиатуры iPad.
    init(
        services: KeyboardServices,
        isPadKeyboard: Bool
    ) {
        self.services = services
        self.isPadKeyboard = isPadKeyboard

        let recentCategory = EmojiCategory.recent
        let initialCategory: EmojiCategory = isPadKeyboard && recentCategory.hasEmojis
            ? recentCategory
            : .smileysAndPeople
        _selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        VStack(spacing: 0) {
            if isPadKeyboard {
                padEmojiGrid
                padBottomBar
            } else {
                compactEmojiGrid
                compactBottomBar
            }
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

    var compactEmojiRows: [GridItem] {
        Array(
            repeating: GridItem(
                .fixed(CompactMetrics.emojiItemHeight),
                spacing: CompactMetrics.rowSpacing
            ),
            count: CompactMetrics.rowCount
        )
    }

    var compactEmojiGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(
                rows: compactEmojiRows,
                spacing: CompactMetrics.rowSpacing
            ) {
                ForEach(selectedCategory.emojis) { emoji in
                    emojiButton(
                        emoji,
                        fontSize: CompactMetrics.emojiFontSize,
                        itemWidth: CompactMetrics.emojiItemWidth,
                        itemHeight: CompactMetrics.emojiItemHeight
                    )
                }
            }
            .padding(.horizontal, CompactMetrics.horizontalPadding)
        }
    }

    var compactBottomBar: some View {
        HStack(spacing: 0) {
            Button("АБВ") {
                services.actionHandler.handle(.keyboardType(.alphabetic))
            }
            .frame(width: CompactMetrics.categoryButtonSize)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            category.symbolIcon
                                .frame(
                                    width: CompactMetrics.categoryButtonSize,
                                    height: CompactMetrics.categoryButtonSize
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
                services.actionHandler.handle(.backspace)
            } label: {
                Image(systemName: "delete.left")
            }
            .frame(width: CompactMetrics.categoryButtonSize)
            .accessibilityLabel("Удалить")
        }
        .buttonStyle(.plain)
        .frame(height: CompactMetrics.bottomBarHeight)
        .padding(.horizontal, CompactMetrics.horizontalPadding)
    }

    /// Рассчитывает число строк эмодзи, помещающихся по высоте на iPad.
    ///
    /// - Parameter availableHeight: Высота области над нижней панелью.
    /// - Returns: Строки сетки в допустимом для iPad диапазоне.
    func padEmojiRows(for availableHeight: CGFloat) -> [GridItem] {
        // Полноразмерные iPad дают расширению разную высоту в книжной и альбомной
        // ориентациях. Число строк выводим из фактической высоты после вычета
        // заголовка, но ограничиваем системным диапазоном: до шести строк на
        // большом экране и не менее четырёх на более компактном.
        let reservedHeight = PadMetrics.topPadding
            + PadMetrics.sectionTitleHeight
            + PadMetrics.sectionTitleBottomSpacing
        let gridHeight = max(0, availableHeight - reservedHeight)
        let rowStride = PadMetrics.emojiItemHeight + PadMetrics.rowSpacing
        let fittingRowCount = Int(
            (gridHeight + PadMetrics.rowSpacing) / rowStride
        )
        let rowCount = min(
            PadMetrics.maximumRowCount,
            max(PadMetrics.minimumRowCount, fittingRowCount)
        )

        return Array(
            repeating: GridItem(
                .fixed(PadMetrics.emojiItemHeight),
                spacing: PadMetrics.rowSpacing
            ),
            count: rowCount
        )
    }

    var padVisibleCategories: [EmojiCategory] {
        // Системная раскладка не обрывает содержимое на границе выбранного
        // раздела: справа сразу начинается следующий. Оставляем в горизонтальной
        // ленте выбранный и все последующие разделы, а кнопка категории переносит
        // начало ленты к соответствующему месту.
        guard let selectedIndex = categories.firstIndex(of: selectedCategory) else {
            return [selectedCategory]
        }

        return Array(categories[selectedIndex...])
    }

    var padEmojiGrid: some View {
        GeometryReader { geometry in
            let rows = padEmojiRows(for: geometry.size.height)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(
                    alignment: .top,
                    spacing: PadMetrics.sectionSpacing
                ) {
                    ForEach(padVisibleCategories) { category in
                        padCategorySection(
                            category,
                            rows: rows
                        )
                    }
                }
                // Без минимальной высоты горизонтальная прокрутка прижимает
                // содержимое к нижней границе, как на исходном снимке приложения.
                // Рамка с верхним выравниванием использует свободную высоту iPad.
                .frame(
                    minHeight: geometry.size.height,
                    alignment: .top
                )
                .padding(.horizontal, PadMetrics.horizontalPadding)
                .padding(.top, PadMetrics.topPadding)
                .id(selectedCategory)
            }
        }
    }

    /// Создаёт раздел одной категории в горизонтальной ленте iPad.
    ///
    /// - Parameters:
    ///   - category: Категория, заголовок и эмодзи которой требуется показать.
    ///   - rows: Рассчитанные строки горизонтальной сетки.
    /// - Returns: Представление заголовка и сетки категории.
    func padCategorySection(
        _ category: EmojiCategory,
        rows: [GridItem]
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: PadMetrics.sectionTitleBottomSpacing
        ) {
            Text(
                category.labelText(for: .russian)
                    .uppercased(with: .russian)
            )
            .font(
                .system(
                    size: PadMetrics.sectionTitleFontSize,
                    weight: .semibold
                )
            )
            .foregroundStyle(.secondary)

            LazyHGrid(
                rows: rows,
                spacing: PadMetrics.columnSpacing
            ) {
                ForEach(category.emojis) { emoji in
                    emojiButton(
                        emoji,
                        fontSize: PadMetrics.emojiFontSize,
                        itemWidth: PadMetrics.emojiItemWidth,
                        itemHeight: PadMetrics.emojiItemHeight
                    )
                }
            }
        }
        .fixedSize(horizontal: true, vertical: true)
    }

    var padBottomBar: some View {
        HStack(spacing: 0) {
            Button("АБВ") {
                services.actionHandler.handle(.keyboardType(.alphabetic))
            }
            .frame(width: PadMetrics.categoryButtonSize)
            .frame(maxHeight: .infinity)

            // Категорий может оказаться больше, чем помещается на узкой или
            // разделённой клавиатуре iPad. Прокручивается только средняя часть,
            // поэтому переход к буквам и служебные кнопки всегда остаются видимыми.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(categories) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            category.symbolIcon
                                .frame(
                                    width: PadMetrics.categoryButtonSize,
                                    height: PadMetrics.categoryButtonSize
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
            .frame(maxWidth: .infinity)

            Button {
                services.actionHandler.handle(.backspace)
            } label: {
                Image(systemName: "delete.left")
            }
            .frame(width: PadMetrics.categoryButtonSize)
            .frame(maxHeight: .infinity)
            .accessibilityLabel("Удалить")

            Button {
                services.actionHandler.handle(.dismissKeyboard)
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
            }
            .frame(width: PadMetrics.categoryButtonSize)
            .frame(maxHeight: .infinity)
            .accessibilityLabel("Скрыть клавиатуру")
        }
        .buttonStyle(.plain)
        .frame(height: PadMetrics.bottomBarHeight)
        .padding(.horizontal, CompactMetrics.horizontalPadding)
    }

    /// Создаёт кнопку эмодзи с заданными размерами.
    ///
    /// - Parameters:
    ///   - emoji: Отображаемый и вставляемый эмодзи.
    ///   - fontSize: Размер шрифта символа.
    ///   - itemWidth: Ширина области нажатия.
    ///   - itemHeight: Высота области нажатия.
    /// - Returns: Кнопка, вставляющая выбранный эмодзи.
    func emojiButton(
        _ emoji: Emoji,
        fontSize: CGFloat,
        itemWidth: CGFloat,
        itemHeight: CGFloat
    ) -> some View {
        Button {
            insert(emoji)
        } label: {
            Text(emoji.char)
                .font(.system(size: fontSize))
                .frame(
                    width: itemWidth,
                    height: itemHeight
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(emoji.localizedName)
    }

    /// Сохраняет эмодзи в недавних и передаёт действие обработчику клавиатуры.
    ///
    /// - Parameter emoji: Эмодзи, выбранный пользователем.
    func insert(_ emoji: Emoji) {
        EmojiCategory.Persisted.recent.addEmoji(emoji)
        services.actionHandler.handle(.emoji(emoji))
    }
}
