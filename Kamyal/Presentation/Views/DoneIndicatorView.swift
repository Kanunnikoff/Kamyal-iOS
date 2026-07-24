//
//  DoneIndicatorView.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import SwiftUI

/// Последовательно показывает значок, сообщение и итоговый значок операции.
struct DoneIndicatorView: View {

    /// Длительности этапов анимации индикатора.
    private enum Constants {

        static let initialPauseNanoseconds: UInt64 = 2_000_000_000
        static let messageDisplayNanoseconds: UInt64 = 4_000_000_000
        static let finalPauseNanoseconds: UInt64 = 1_000_000_000
    }

    let message: LocalizedStringKey
    let startImageName: String
    let endImageName: String

    @State private var isImageVisible = false
    @State private var isMessageVisible = false
    @State private var imageName: String

    @ScaledMetric private var indicatorHeight = 80.0

    /// Создаёт анимированный индикатор завершённой операции.
    ///
    /// - Parameters:
    ///   - message: Сообщение, показываемое между начальным и итоговым значками.
    ///   - startImageName: Имя начального символа SF Symbols.
    ///   - endImageName: Имя итогового символа SF Symbols.
    init(
        message: LocalizedStringKey,
        startImageName: String = "arrow.down.circle",
        endImageName: String = "checkmark.circle"
    ) {
        self.message = message
        self.startImageName = startImageName
        self.endImageName = endImageName
        _imageName = State(initialValue: startImageName)
    }

    var body: some View {
        HStack(spacing: 0) {
            if isImageVisible {
                Image(systemName: imageName)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.pink, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .font(.title)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .transition(.scale(scale: 0.25).combined(with: .opacity))
            }

            if isMessageVisible {
                Text(message)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 26)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
        }
        .background(
            .regularMaterial.shadow(
                .drop(
                    color: .black.opacity(0.15),
                    radius: 20,
                    y: 10
                )
            ),
            in: Capsule()
        )
        .padding()
        .frame(height: indicatorHeight)
        .task {
            await animateIndicator()
        }
    }

    /// Выполняет этапы появления сообщения и смены значков.
    private func animateIndicator() async {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isImageVisible = true
        }

        try? await Task.sleep(nanoseconds: Constants.initialPauseNanoseconds)

        guard !Task.isCancelled else {
            return
        }

        withAnimation {
            isMessageVisible = true
        }

        try? await Task.sleep(nanoseconds: Constants.messageDisplayNanoseconds)

        guard !Task.isCancelled else {
            return
        }

        withAnimation {
            imageName = endImageName
            isMessageVisible = false
        }

        try? await Task.sleep(nanoseconds: Constants.finalPauseNanoseconds)

        guard !Task.isCancelled else {
            return
        }

        withAnimation {
            isImageVisible = false
        }
    }
}

/// Предварительный просмотр индикатора завершения.
struct DoneIndicatorView_Previews: PreviewProvider {

    static var previews: some View {
        DoneIndicatorView(message: "Большое спасибо за поддержку!")
    }
}
