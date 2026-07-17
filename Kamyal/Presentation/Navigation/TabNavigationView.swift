//
//  TabNavigationView.swift
//  Kamyal
//
//  Created by Codex on 12.07.2026.
//

import SwiftUI

private enum TabSelection: Hashable {

    case main
    case alphabet
    case settings
    case about
}

struct TabNavigationView: View {

    @AppStorage(AppSettingsKey.isIngush)
    private var isIngush: Bool = false

    @State private var selectedTab: TabSelection = .main

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MainView()
            }
            .tabItem {
                Label(isIngush ? "Керттера оагӀув" : "Главная", systemImage: "house")
            }
            .tag(TabSelection.main)

            NavigationStack {
                AlphabetView()
            }
            .tabItem {
                Label("Алфавит", systemImage: "textformat.abc")
            }
            .tag(TabSelection.alphabet)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(isIngush ? "Оттамаш" : "Настройки", systemImage: "gear")
            }
            .tag(TabSelection.settings)

            NavigationStack {
                AboutView()
            }
            .tabItem {
                Label(isIngush ? "Программах лаьца" : "О программе", systemImage: "info.circle")
            }
            .tag(TabSelection.about)
        }
    }
}

struct TabNavigationView_Previews: PreviewProvider {

    static var previews: some View {
        TabNavigationView()
    }
}
