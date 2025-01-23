//
//  MainTabView.swift
//  munchies
//
//  Created by Mohammad Rahim on 1/22/25.
//
import SwiftUI

struct MainTabView: View {
    init() {
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "map")
                }
            
            Text("Bookmarks")
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .accentColor(.blue)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
