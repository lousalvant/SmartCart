//
//  SmartCartApp.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import FirebaseCore

@main
struct SmartCartApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var settingsViewModel = SettingsViewModel() // Initialize SettingsViewModel here

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                HomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(settingsViewModel) // Pass to HomeView
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
