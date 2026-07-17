//
//  MyAutocompleteToolbar.swift
//  keyboard
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import KeyboardKit
import SwiftUI

enum MyAutocompleteToolbar {

    private enum Metrics {

        static let padHeight: CGFloat = 20
        static let phoneHeight: CGFloat = 29
        static let firstSeparatorPosition: CGFloat = 1 / 3
        static let separatorHorizontalOffset: CGFloat = -2 / 3
        static let secondSeparatorPosition: CGFloat = 2 / 3
        static let separatorHeight: CGFloat = 24
        static let separatorOpacity = 0.215
        static let separatorTopOffset: CGFloat = -2
        static let separatorWidth: CGFloat = 1
    }

    static func style(isPadKeyboard: Bool) -> AutocompleteToolbarStyle {
        var style = AutocompleteToolbarStyle.standard

        // На iPad над расширением уже находится системная строка быстрых действий.
        // Уменьшаем только дополнительную полосу наших подсказок, не меняя
        // привычную высоту панели на iPhone, где системного ряда нет.
        style.height = isPadKeyboard ? Metrics.padHeight : Metrics.phoneHeight

        // Собственные разделители всегда занимают границы трёх системных ячеек.
        // Стандартные разделители KeyboardKit скрываем, чтобы после появления
        // предложений они не накладывались на постоянные линии второй раз.
        style.separator.color = .clear

        return style
    }

    /// Рисует линии относительно корня клавиатуры, а не внутри самой полосы
    /// подсказок. KeyboardKit частично размещает полосу выше границы расширения,
    /// из-за чего четыре верхних пикселя линий обрезались при возврате с другой
    /// клавиатуры. Корневой слой сохраняет системные координаты целиком.
    static var separators: some View {
        GeometryReader { geometry in
            separator
                .position(
                    x: geometry.size.width * Metrics.firstSeparatorPosition
                        + Metrics.separatorHorizontalOffset,
                    y: Metrics.separatorTopOffset + Metrics.separatorHeight / 2
                )

            separator
                .position(
                    x: geometry.size.width * Metrics.secondSeparatorPosition
                        + Metrics.separatorHorizontalOffset,
                    y: Metrics.separatorTopOffset + Metrics.separatorHeight / 2
                )
        }
        .allowsHitTesting(false)
    }
}

private extension MyAutocompleteToolbar {

    static var separator: some View {
        Capsule()
            .fill(Color.secondary.opacity(Metrics.separatorOpacity))
            .frame(
                width: Metrics.separatorWidth,
                height: Metrics.separatorHeight
            )
    }
}
