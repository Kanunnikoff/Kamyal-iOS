//
//  Sidebat.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

enum SidebarItem: Hashable {
    case main
    case settings
    case about
}

struct Sidebar: View {
    
    @Binding var selection: SidebarItem?
    
    @AppStorage("SettingsView.isIngush")
    private var isIngush: Bool = false
    
    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: SidebarItem.main) {
                Label(isIngush ? "Керттера оагӀув" : "Главная", systemImage: "house")
            }
            
            NavigationLink(value: SidebarItem.settings) {
                Label(isIngush ? "Оттамаш" : "Настройки", systemImage: "gear")
            }
            
            NavigationLink(value: SidebarItem.about) {
                Label(isIngush ? "Программах лаьца" : "О программе", systemImage: "info.circle")
            }
        }
        .navigationTitle("Меню")
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 200)
#endif
    }
}

struct Sidebar_Previews: PreviewProvider {
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
