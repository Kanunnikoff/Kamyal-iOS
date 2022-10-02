//
//  MyKeyboard.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

#if os(iOS) || os(tvOS)
import SwiftUI
import KeyboardKit

public struct MyKeyboard<ButtonView: View>: View {
    
    /**
     Create a system keyboard that uses a custom `buttonView`
     to customize the entire view for each layout item.
     */
    public init(
        layout: KeyboardLayout,
        appearance: KeyboardAppearance,
        actionHandler: KeyboardActionHandler,
        keyboardContext: KeyboardContext,
        actionCalloutContext: ActionCalloutContext?,
        inputCalloutContext: InputCalloutContext?,
        width: CGFloat? = nil,
        @ViewBuilder buttonView: @escaping ButtonViewBuilder
    ) {
        let width = width ?? Self.standardKeyboardWidth
        
        self.layout = layout
        self.layoutConfig = .standard(for: keyboardContext)
        self.actionHandler = actionHandler
        self.appearance = appearance
        self.keyboardWidth = width
        self.buttonView = buttonView
        self.inputWidth = layout.inputWidth(for: width)
        
        _keyboardContext = ObservedObject(wrappedValue: keyboardContext)
        _actionCalloutContext = ObservedObject(wrappedValue: actionCalloutContext ?? .disabled)
        _inputCalloutContext = ObservedObject(wrappedValue: inputCalloutContext ?? .disabled)
    }
    
    /**
     Create a system keyboard that uses a custom `buttonView`
     to customize the entire view for each layout item.
     */
    init(
        controller: KeyboardInputViewController? = nil,
        width: CGFloat? = nil,
        @ViewBuilder buttonView: @escaping ButtonViewBuilder
    ) {
        let controller = controller ?? .shared
        
        self.init(
            layout: controller.keyboardLayoutProvider.keyboardLayout(for: controller.keyboardContext),
            appearance: controller.keyboardAppearance,
            actionHandler: controller.keyboardActionHandler,
            keyboardContext: controller.keyboardContext,
            actionCalloutContext: controller.actionCalloutContext,
            inputCalloutContext: controller.inputCalloutContext,
            width: width,
            buttonView: buttonView
        )
    }
    
    private let actionHandler: KeyboardActionHandler
    private let appearance: KeyboardAppearance
    private let buttonView: ButtonViewBuilder
    private let keyboardWidth: CGFloat
    private let inputWidth: CGFloat
    private let layout: KeyboardLayout
    private let layoutConfig: KeyboardLayoutConfiguration
    
    public typealias ButtonViewBuilder = (KeyboardLayoutItem, KeyboardWidth, KeyboardItemWidth) -> ButtonView
    public typealias KeyboardWidth = CGFloat
    public typealias KeyboardItemWidth = CGFloat
    
    private var actionCalloutStyle: ActionCalloutStyle {
        var style = appearance.actionCalloutStyle()
        let insets = layoutConfig.buttonInsets
        style.callout.buttonInset = CGSize(width: insets.leading, height: insets.top)
        return style
    }
    
    private var inputCalloutStyle: InputCalloutStyle {
        var style = appearance.inputCalloutStyle()
        let insets = layoutConfig.buttonInsets
        style.callout.buttonInset = CGSize(width: insets.leading, height: insets.top)
        return style
    }
    
    @ObservedObject private var actionCalloutContext: ActionCalloutContext
    @ObservedObject private var inputCalloutContext: InputCalloutContext
    @ObservedObject private var keyboardContext: KeyboardContext
    
    public var body: some View {
        if #available(iOS 14.0, tvOS 14.0, *) {
            switch keyboardContext.keyboardType {
                case .emojis: emojiKeyboard
                default: myKeyboard
            }
        } else {
            myKeyboard
        }
    }
}

public extension MyKeyboard where ButtonView == SystemKeyboardButtonRowItem<SystemKeyboardActionButtonContent> {
    
    /**
     Create a system keyboard view that uses standard button
     views for all layout items.
     
     See ``SystemKeyboard/standardButtonView(item:appearance:actionHandler:keyboardContext:keyboardWidth:inputWidth:)`` for more info.
     */
    init(
        layout: KeyboardLayout,
        appearance: KeyboardAppearance,
        actionHandler: KeyboardActionHandler,
        keyboardContext: KeyboardContext,
        actionCalloutContext: ActionCalloutContext?,
        inputCalloutContext: InputCalloutContext?,
        width: CGFloat? = nil
    ) {
        self.init(
            layout: layout,
            appearance: appearance,
            actionHandler: actionHandler,
            keyboardContext: keyboardContext,
            actionCalloutContext: actionCalloutContext,
            inputCalloutContext: inputCalloutContext,
            width: width,
            buttonView: { item, keyboardWidth, inputWidth in
                Self.standardButtonView(
                    item: item,
                    appearance: appearance,
                    actionHandler: actionHandler,
                    keyboardContext: keyboardContext,
                    keyboardWidth: keyboardWidth,
                    inputWidth: inputWidth
                )
            }
        )
    }
    
    /**
     Create a system keyboard view that uses standard button
     views for all layout items.
     
     See ``SystemKeyboard/standardButtonView(item:appearance:actionHandler:keyboardContext:keyboardWidth:inputWidth:)`` for more info.
     */
    init(
        controller: KeyboardInputViewController? = nil,
        width: CGFloat? = nil
    ) {
        let controller = controller ?? .shared
        self.init(
            layout: controller.keyboardLayoutProvider.keyboardLayout(for: controller.keyboardContext),
            appearance: controller.keyboardAppearance,
            actionHandler: controller.keyboardActionHandler,
            keyboardContext: controller.keyboardContext,
            actionCalloutContext: controller.actionCalloutContext,
            inputCalloutContext: controller.inputCalloutContext,
            width: width
        )
    }
}

public extension MyKeyboard where ButtonView == SystemKeyboardButtonRowItem<AnyView> {
    
    /**
     Create a system keyboard view that uses `buttonContent`
     to customize the content of each layout item.
     */
    init<ButtonContentView: View>(
        layout: KeyboardLayout,
        appearance: KeyboardAppearance,
        actionHandler: KeyboardActionHandler,
        keyboardContext: KeyboardContext,
        actionCalloutContext: ActionCalloutContext?,
        inputCalloutContext: InputCalloutContext?,
        width: CGFloat? = nil,
        @ViewBuilder buttonContent: @escaping (KeyboardLayoutItem) -> ButtonContentView
    ) {
        
        self.init(
            layout: layout,
            appearance: appearance,
            actionHandler: actionHandler,
            keyboardContext: keyboardContext,
            actionCalloutContext: actionCalloutContext,
            inputCalloutContext: inputCalloutContext,
            width: width,
            buttonView: { item, keyboardWidth, inputWidth in
                SystemKeyboardButtonRowItem(
                    content: AnyView(buttonContent(item)),
                    item: item,
                    context: keyboardContext,
                    keyboardWidth: keyboardWidth,
                    inputWidth: inputWidth,
                    appearance: appearance,
                    actionHandler: actionHandler
                )
            }
        )
    }
    
    /**
     Create a system keyboard view that uses `buttonContent`
     to customize the content of each layout item.
     */
    init<ButtonContentView: View>(
        controller: KeyboardInputViewController? = nil,
        width: CGFloat? = nil,
        @ViewBuilder buttonContent: @escaping (KeyboardLayoutItem) -> ButtonContentView
    ) {
        let controller = controller ?? .shared
        self.init(
            layout: controller.keyboardLayoutProvider.keyboardLayout(for: controller.keyboardContext),
            appearance: controller.keyboardAppearance,
            actionHandler: controller.keyboardActionHandler,
            keyboardContext: controller.keyboardContext,
            actionCalloutContext: controller.actionCalloutContext,
            inputCalloutContext: controller.inputCalloutContext,
            width: width,
            buttonContent: buttonContent
        )
    }
}

public extension MyKeyboard {
    
    /**
     The standard view to use as button content.
     */
    static func standardButtonContent(
        item: KeyboardLayoutItem,
        appearance: KeyboardAppearance,
        keyboardContext: KeyboardContext
    ) -> SystemKeyboardActionButtonContent {
        
        SystemKeyboardActionButtonContent(
            action: item.action,
            appearance: appearance,
            context: keyboardContext
        )
    }
    
    /**
     The standard view to use as button view.
     */
    static func standardButtonView(
        item: KeyboardLayoutItem,
        appearance: KeyboardAppearance,
        actionHandler: KeyboardActionHandler,
        keyboardContext: KeyboardContext,
        keyboardWidth: KeyboardWidth,
        inputWidth: KeyboardItemWidth
    ) -> SystemKeyboardButtonRowItem<SystemKeyboardActionButtonContent> {
        
        SystemKeyboardButtonRowItem(
            content: standardButtonContent(
                item: item,
                appearance: appearance,
                keyboardContext: keyboardContext
            ),
            item: item,
            context: keyboardContext,
            keyboardWidth: keyboardWidth,
            inputWidth: inputWidth,
            appearance: appearance,
            actionHandler: actionHandler
        )
    }
}

public extension MyKeyboard {
    
    /**
     This is the standard keyboard width, which is retrieved
     from ``KeyboardInputViewController/shared``.
     */
    static var standardKeyboardWidth: CGFloat {
        KeyboardInputViewController.shared.view.frame.width
    }
}

private extension MyKeyboard {
    
    @available(iOS 14.0, tvOS 14.0, *)
    var emojiKeyboard: some View {
        EmojiCategoryKeyboard(
            appearance: appearance,
            context: keyboardContext,
            style: .standard(for: keyboardContext)
        )
        .padding(.top)
    }
    
    var myKeyboard: some View {
        VStack(spacing: 0) {
            itemRows(for: layout)
        }
        .actionCallout(
            context: actionCalloutContext,
            style: actionCalloutStyle
        )
        .inputCallout(
            context: inputCalloutContext,
            keyboardContext: keyboardContext,
            style: inputCalloutStyle
        )
        .environment(\.layoutDirection, .leftToRight)
    }
}

private extension MyKeyboard {
    
    func itemRows(for layout: KeyboardLayout) -> some View {
        ForEach(Array(layout.itemRows.enumerated()), id: \.offset) {
            items(for: layout, itemRow: $0.element)
        }
    }
    
    func items(for layout: KeyboardLayout, itemRow: KeyboardLayoutItemRow) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(itemRow.enumerated()), id: \.offset) {
                buttonView($0.element, keyboardWidth, inputWidth)
            }
        }
    }
}
#endif
