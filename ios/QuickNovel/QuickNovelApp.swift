//
//  QuickNovelApp.swift
//  QuickNovel
//
//  Created by QuickNovel Team on 2026-01-19.
//

import SwiftUI

@main
struct QuickNovelApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Configure global app settings
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Initialize providers
                    ProviderRegistry.shared.registerAllProviders()
                }
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var isLoading = false
    
    enum Tab {
        case home
        case search
        case downloads
        case history
        case settings
    }
}
