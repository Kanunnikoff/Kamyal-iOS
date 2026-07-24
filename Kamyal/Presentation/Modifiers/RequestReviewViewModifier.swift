//
//  RequestReviewViewModifier.swift
//  Kamyal
//

import StoreKit
import SwiftUI

/// Запрашивает оценку приложения после заданного числа запусков каждой сборки.
struct RequestReviewViewModifier: ViewModifier {

#if !os(tvOS) && !os(watchOS)
    /// Ключи сохранённого состояния запроса оценки.
    private enum StorageKey {

        static let launchesCount = "Util.launchesCount"
        static let lastVersionPromtedForReview = "Util.lastVersionPromtedForReview"
    }

    /// Временные параметры запроса оценки.
    private enum Metrics {

        static let requestDelaySeconds: TimeInterval = 1
    }

    @AppStorage(StorageKey.launchesCount)
    private var launchesCount = 0

    @AppStorage(StorageKey.lastVersionPromtedForReview)
    private var lastVersionPromtedForReview = ""

    // SwiftUI устанавливает настоящее действие запроса оценки только для свойства,
    // принадлежащего представлению или его модификатору в активной иерархии.
    @Environment(\.requestReview)
    private var requestReview
#endif

    /// Подключает проверку условий запроса оценки при появлении содержимого.
    ///
    /// - Parameter content: Исходное содержимое представления.
    func body(content: Content) -> some View {
        content
#if !os(tvOS) && !os(watchOS)
            .onAppear {
                requestReviewIfNeeded()
            }
#endif
    }
}

#if !os(tvOS) && !os(watchOS)
private extension RequestReviewViewModifier {

    /// Увеличивает счётчик запусков и при выполнении условий показывает системный запрос.
    func requestReviewIfNeeded() {
        launchesCount += 1

        let currentVersion = Util.getAppBuild()
        guard launchesCount >= Config.REQUEST_REVIEW_LAUNCHES_COUNT_THRESHOLD,
              currentVersion != lastVersionPromtedForReview else {
            return
        }

        // Небольшая задержка позволяет корневому интерфейсу полностью появиться:
        // системный запрос оценки, вызванный во время построения экрана, может быть проигнорирован.
        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.requestDelaySeconds) {
            requestReview()
            lastVersionPromtedForReview = currentVersion
        }
    }
}
#endif

extension View {

    /// Подключает автоматический запрос оценки к представлению.
    ///
    /// - Returns: Представление с учётом числа запусков и уже запрошенной сборки.
    func requestReview() -> some View {
        modifier(RequestReviewViewModifier())
    }
}
