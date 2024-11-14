//
//  ShoppingView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import CoreLocation

struct ShoppingView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var showListSheet = false
    @State private var location: String = "Detecting..."
    @State private var itemList: [(name: String, price: Double)] = []
    @State private var showCartSummary = false

    var body: some View {
        VStack(spacing: 20) {
            // Top Section
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
                .frame(height: 250)
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
        .onAppear(perform: detectLocation)
        .sheet(isPresented: $showListSheet) {
            ViewListSheetView()
                .environmentObject(viewModel) // Pass environment object to ViewListSheetView
        }
    }

    private func detectLocation() {
        location = "Florida" // Placeholder for actual location detection
    }
}

// Subview for Viewing and Checking Off the List
struct ViewListSheetView: View {
    @EnvironmentObject var viewModel: SettingsViewModel // Directly access the view model
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Your List")
                .font(.headline)
                .padding()

            List(viewModel.groceryList, id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    Button(action: {
                        viewModel.toggleCheck(for: item) // Directly use toggleCheck on the view model
                    }) {
                        Image(systemName: viewModel.checkedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.checkedItems.contains(item) ? .green : .gray)
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
}
