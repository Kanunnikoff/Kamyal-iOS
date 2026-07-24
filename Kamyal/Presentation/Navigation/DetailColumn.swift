//
//  DetailColumn.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

/// Показывает экран, выбранный в боковой панели.
struct DetailColumn: View {
    
    @Binding var selection: SidebarItem?
    
    var body: some View {
        switch selection ?? .main {
            case .main:
                MainView()
            case .alphabet:
                AlphabetView()
            case .settings:
                SettingsView()
            case .about:
                AboutView()
        }
    }
}

/// Предварительный просмотр столбца с выбранным экраном.
struct DetailColumn_Previews: PreviewProvider {

    /// Хранит изменяемый выбор экрана для предварительного просмотра.
    struct Preview: View {
        
        @State private var selection: SidebarItem? = .main
        
        var body: some View {
            DetailColumn(selection: $selection)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
