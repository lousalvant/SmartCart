//
//  ShoppingView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI

struct ShoppingView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel // Access SettingsViewModel
    @State private var cartItems: [String] = [] // Track items in the cart
    @State private var newItem = "" // Input for new item
    @State private var showCartSummary = false // Control navigation to CartSummaryView

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Display store, budget, and location at the top
                VStack(alignment: .leading, spacing: 10) {
                    Text("Store: \(settingsViewModel.storeName)")
                        .font(.headline)
                    
                    if let budget = settingsViewModel.budget {
                        Text("Budget: \(settingsViewModel.currencyFormatter.string(from: NSNumber(value: budget)) ?? "$0.00")")
                            .font(.headline)
                    } else {
                        Text("Budget: Not Set")
                            .font(.headline)
                    }
                }
                .padding()

                Divider()

                // Section for the cart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Cart")
                        .font(.title2)
                        .bold()

                    // Display items in the cart
                    List {
                        ForEach(cartItems, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete(perform: deleteItem)
                    }
                    .frame(height: 200) // Limit height of the cart list
                    
                    // Add new item to cart
                    HStack {
                        TextField("Add Item", text: $newItem)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                }
                .padding()

                Spacer()

                // Finished button at the bottom
                Button(action: {
                    showCartSummary = true
                }) {
                    Text("Finished")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .navigationDestination(isPresented: $showCartSummary) {
                    CartSummaryView()
                }
            }
            .navigationTitle("Shopping Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Add new item to the cart
    private func addItem() {
        guard !newItem.isEmpty else { return }
        cartItems.append(newItem)
        newItem = ""
    }

    // Delete item from the cart
    private func deleteItem(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
}
