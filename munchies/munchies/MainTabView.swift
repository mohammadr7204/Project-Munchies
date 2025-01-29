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
            // Your existing Home tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "map")
                }
            
            // Add the Bookmarks tab
                        BookmarksView()
                            .tabItem {
                                Label("Bookmarks", systemImage: "bookmark")
                            }
            // Your existing Profile tab
            ProfileView()
                            .tabItem {
                                Image(systemName: "person.fill")
                                Text("Profile")
                            }
        }
        .accentColor(.blue)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
