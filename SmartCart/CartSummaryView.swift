//
//  CartSummary.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/10/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

struct CartSummaryView: View {
    let store: String
    let cartItems: [(name: String, price: Double, quantity: Int)]
    let subtotal: Double
    let salesTax: Double
    let estimatedTotal: Double
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss // Used to navigate back to HomeView

    @State private var isSaving = false // To show a loading indicator or disable the button if needed
    @State private var saveError: String? // To handle errors if saving fails

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Store: \(store)")
                .font(.headline)
                .padding(.horizontal)
            
            Divider()
            
            Text("Items")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            // List of items
            List(cartItems, id: \.name) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text("Quantity: \(item.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(String(format: "$%.2f", item.price * Double(item.quantity)) )
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Spacer()
            
            // Summary section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Subtotal:")
                    Spacer()
                    Text(String(format: "$%.2f", subtotal))
                }
                HStack {
                    Text("Sales Tax:")
                    Spacer()
                    Text(String(format: "$%.2f", salesTax))
                }
                HStack {
                    Text("Estimated Total:")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", estimatedTotal))
                        .font(.headline)
                }
            }
            .padding()
            
            Spacer()
            
            // Error message if saving fails
            if let saveError = saveError {
                Text("Error: \(saveError)")
                    .foregroundColor(.red)
                    .padding()
            }

            // Done button
            Button(action: saveAndDismiss) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .disabled(isSaving)
            .padding(.horizontal)
        }
        .navigationTitle("Cart Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveAndDismiss() {
        isSaving = true
        saveError = nil

        let session = ShoppingSession(
            id: UUID().uuidString,
            store: store,
            date: Date(),
            items: cartItems.map { ShoppingSession.CartItem(name: $0.name, quantity: $0.quantity, price: $0.price) },
            subtotal: subtotal,
            salesTax: salesTax,
            estimatedTotal: estimatedTotal
        )
        
        settingsViewModel.saveShoppingSession(session) { result in
            isSaving = false
            switch result {
            case .success:
                print("Shopping session saved successfully!")
                dismiss()
            case .failure(let error):
                print("Error saving session: \(error.localizedDescription)")
                saveError = error.localizedDescription
            }
        }
    }
}
