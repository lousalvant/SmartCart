//
//  ShoppingView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import CoreLocation

struct ShoppingView: View {
    @EnvironmentObject var viewModel: SettingsViewModel // Access the SettingsViewModel
    @State private var showListSheet = false
    @State private var location: String = "Detecting..." // Display detected location
    @State private var itemList: [(name: String, price: Double)] = [] // List of items and their prices
    @State private var showCartSummary = false

    var body: some View {
        VStack(spacing: 20) {
            // Top Section: Store, Location, and Budget
            VStack {
                Text("Shopping at \(viewModel.storeName)")
                    .font(.headline)
                Text("Location: \(location)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Budget: \(viewModel.currencyFormatter.string(from: NSNumber(value: viewModel.budget ?? 0)) ?? "$0.00")")
                    .font(.subheadline)
            }
            .padding(.top)

            // Buttons Section
            HStack(spacing: 20) {
                Button(action: {
                    showListSheet = true
                }) {
                    Text("View List")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Implement scanning functionality
                }) {
                    Text("Scan Item")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button(action: {
                    // Implement manual entry functionality
                }) {
                    Text("Enter Item")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            // Progress Section
            VStack(alignment: .leading) {
                Text("Items in Cart:")
                    .font(.headline)
                    .padding(.horizontal)

                List(itemList, id: \.name) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text(viewModel.currencyFormatter.string(from: NSNumber(value: item.price)) ?? "$0.00")
                    }
                }
                .frame(height: 250) // Adjust list height as needed
            }

            Spacer()

            // Finished Button
            Button(action: {
                showCartSummary = true
            }) {
                Text("Finished")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .navigationDestination(isPresented: $showCartSummary) {
                CartSummaryView()
            }
        }
        .padding()
        .onAppear(perform: detectLocation) // Call location detection on view load
        .sheet(isPresented: $showListSheet) {
            ViewListSheetView(itemList: $viewModel.groceryList)
        }
    }

    // Location Detection (Mock implementation here; replace with actual location service)
    private func detectLocation() {
        // Mock location setting; replace with actual location detection
        location = "Florida" // For example purposes; use CLLocationManager for actual detection
    }
}

// Subview for Viewing and Checking Off the List
struct ViewListSheetView: View {
    @Binding var itemList: [String]
    @Environment(\.dismiss) var dismiss
    @State private var checkedItems: Set<String> = [] // Track checked items here

    var body: some View {
        VStack {
            Text("Your List")
                .font(.headline)
                .padding()

            List(itemList, id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    Button(action: {
                        toggleCheck(for: item)
                    }) {
                        Image(systemName: checkedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(checkedItems.contains(item) ? .green : .gray)
                    }
                }
            }
            .padding()

            Button("Close") {
                dismiss()
            }
            .padding()
        }
    }

    // Toggle the check state of an item
    private func toggleCheck(for item: String) {
        if checkedItems.contains(item) {
            checkedItems.remove(item)
        } else {
            checkedItems.insert(item)
        }
    }
}
