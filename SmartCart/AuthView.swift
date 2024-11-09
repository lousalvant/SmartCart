//
//  AuthView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                // Custom centered title
                Text("SmartCart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 70)
                
                // Spacer to push the title to the top
                Spacer()
                
                // Login/Signup picker
                Picker("Login or Signup", selection: $isLoginMode) {
                    Text("Login").tag(true)
                    Text("Sign Up").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Email and Password fields
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Login/Sign Up button
                Button(action: handleAction) {
                    Text(isLoginMode ? "Log In" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                // Error message display
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer() // Bottom Spacer to ensure even padding
            }
            .padding()
        }
    }

    private func handleAction() {
        if isLoginMode {
            authViewModel.login(email: email, password: password)
        } else {
            authViewModel.signUp(email: email, password: password)
        }
    }
}
