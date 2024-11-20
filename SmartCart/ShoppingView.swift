//
//  ShoppingView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI

struct ShoppingView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel // Access SettingsViewModel
    @State private var cartItems: [(name: String, price: Double)] = [] // Track items in the cart with price
    @State private var showItemEntrySheet = false // Show sheet for item entry
    @State private var showCartSummary = false // Control navigation to CartSummaryView

    // Compute the total price of items in the cart
    private var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.price }
    }

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
                        ForEach(cartItems, id: \.name) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text(settingsViewModel.currencyFormatter.string(from: NSNumber(value: item.price)) ?? "$0.00")
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                    .frame(height: 200) // Limit height of the cart list
                    
                    // Total price below the cart
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text(settingsViewModel.currencyFormatter.string(from: NSNumber(value: totalPrice)) ?? "$0.00")
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    // Add item button
                    Button(action: {
                        showItemEntrySheet = true
                    }) {
                        Text("Enter Item")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
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
            .sheet(isPresented: $showItemEntrySheet) {
                ItemEntryView { itemName, itemPrice in
                    addItem(name: itemName, price: itemPrice)
                }
            }
        }
    }

    // Add new item to the cart
    private func addItem(name: String, price: Double) {
        cartItems.append((name: name, price: price))
    }

    // Delete item from the cart
    private func deleteItem(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
}

// A new view for item entry
struct ItemEntryView: View {
    @Environment(\.dismiss) var dismiss // Control sheet dismissal
    @State private var itemName = ""
    @State private var itemPriceText = ""
    var onSave: (String, Double) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Enter Item Details")
                    .font(.title2)
                    .bold()

                TextField("Item Name", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Item Price", text: $itemPriceText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: saveItem) {
                    Text("Enter")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveItem() {
        guard !itemName.isEmpty, let itemPrice = Double(itemPriceText) else { return }
        onSave(itemName, itemPrice)
        dismiss()
    }
}
