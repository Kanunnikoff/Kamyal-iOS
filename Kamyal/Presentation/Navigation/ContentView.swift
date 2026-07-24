//
//  ContentView.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 09.07.2022.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

/// Выбирает подходящую для устройства схему навигации приложения.
struct ContentView: View {
    
    @State private var selection: SidebarItem? = SidebarItem.main
    @State private var path = NavigationPath()
    
    var body: some View {
        Group {
            if prefersTabNavigation {
                TabNavigationView()
            } else {
                NavigationSplitView {
                    Sidebar(selection: $selection)
                } detail: {
                    NavigationStack(path: $path) {
                        DetailColumn(selection: $selection)
                    }
                }
                .onChange(of: selection) { _ in
                    path.removeLast(path.count)
                }
            }
        }
        .requestReview()
#if os(macOS)
        .frame(minWidth: 600, minHeight: 450)
#endif
    }

    private var prefersTabNavigation: Bool {
#if os(iOS)
        // Как и в «Яти», на телефоне используем нижнюю панель, а на iPad
        // оставляем системную боковую панель независимо от текущей ширины окна.
        UIDevice.current.userInterfaceIdiom == .phone
#else
        false
#endif
    }
}

/// Предварительный просмотр корневого представления.
struct ContentView_Previews: PreviewProvider {

    /// Обёртка корневого представления для предварительного просмотра.
    struct Preview: View {
        
        var body: some View {
            ContentView()
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
