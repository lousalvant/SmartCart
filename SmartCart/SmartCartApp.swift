//
//  SmartCartApp.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import FirebaseCore // Import FirebaseCore to initialize Firebase

@main
struct SmartCartApp: App {
    // Initialize Firebase in the app initializer
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
