//
//  Sidebat.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

/// Разделы, доступные в основной навигации приложения.
enum SidebarItem: Hashable {
    case main
    case alphabet
    case settings
    case about
}

/// Боковая панель навигации для iPad и других широких окон.
struct Sidebar: View {
    
    @Binding var selection: SidebarItem?
    
    @AppStorage(AppSettingsKey.isIngush)
    private var isIngush: Bool = false
    
    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: SidebarItem.main) {
                Label(isIngush ? "Керттера оагӀув" : "Главная", systemImage: "house")
            }

            NavigationLink(value: SidebarItem.alphabet) {
                Label("Алфавит", systemImage: "textformat.abc")
            }
            
            NavigationLink(value: SidebarItem.settings) {
                Label(isIngush ? "Оттамаш" : "Настройки", systemImage: "gear")
            }
            
            NavigationLink(value: SidebarItem.about) {
                Label(isIngush ? "Программах лаьца" : "О программе", systemImage: "info.circle")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Меню")
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 200)
#endif
    }
}

/// Предварительный просмотр боковой панели.
struct Sidebar_Previews: PreviewProvider {

    /// Хранит изменяемый выбор раздела для предварительного просмотра.
    struct Preview: View {
        @State private var selection: SidebarItem? = SidebarItem.main
        var body: some View {
            Sidebar(selection: $selection)
        }
    }
    
    static var previews: some View {
        NavigationSplitView {
            Preview()
        } detail: {
            Text("Detail!")
        }
    }
}
