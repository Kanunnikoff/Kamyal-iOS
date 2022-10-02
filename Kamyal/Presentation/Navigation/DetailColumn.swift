//
//  DetailColumn.swift
//  Kamyal
//
//  Created by Дмитрiй Канунниковъ on 13.09.2022.
//

import SwiftUI

struct DetailColumn: View {
    
    @Binding var selection: SidebarItem?
    
    var body: some View {
        switch selection ?? .main {
            case .main:
                MainView()
            case .settings:
                SettingsView()
            case .about:
                AboutView()
        }
    }
}

struct DetailColumn_Previews: PreviewProvider {
    
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
