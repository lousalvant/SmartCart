//
//  AuthViewModel.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    init() {
        self.isAuthenticated = Auth.auth().currentUser != nil // Check for an existing session for persisted login
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.isAuthenticated = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false // Update authentication state
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
}
