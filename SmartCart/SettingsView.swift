//
//  SettingsView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

class SettingsViewModel: ObservableObject {
    @Published var storeName = "Select a Store"
    @Published var budget: Double? = nil
    @Published var groceryList = [String]()
    @Published var newGroceryItem = ""
    
    // Currency formatter
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencySymbol = "$" // Adjust according to your currency
        return formatter
    }()
    
    // List of store options
    let storeOptions = ["ALDI", "Costco", "Publix", "The Fresh Market", "Walmart", "WholeFoods", "Winn-Dixie", "Other"]
    
    func saveGroceryList() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let document = db.collection("users").document(userID).collection("groceryLists").document()

        document.setData([
            "storeName": storeName,
            "budget": budget ?? 0.0,
            "groceryList": groceryList,
            "createdAt": Timestamp()
        ]) { error in
            if let error = error {
                print("Error saving grocery list: \(error.localizedDescription)")
            } else {
                print("Grocery list saved successfully.")
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showShoppingView = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Set Up Your Shopping Trip")
                    .font(.title)
                    .padding(.top)

                // Store Picker
                VStack(alignment: .leading) {
                    Text("Select Store")
                        .font(.headline)
                        .padding(.horizontal)

                    Picker("Select a Store", selection: $viewModel.storeName) {
                        ForEach(viewModel.storeOptions, id: \.self) { store in
                            Text(store)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }

                // Budget
                VStack(alignment: .leading) {
                    Text("Budget")
                        .font(.headline)
                        .padding(.horizontal)

                    TextField("Enter Budget", value: $viewModel.budget, formatter: viewModel.currencyFormatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                // Grocery List
                VStack(alignment: .leading) {
                    Text("Grocery List")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        TextField("Add Item", text: $viewModel.newGroceryItem)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    List {
                        ForEach(viewModel.groceryList, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete(perform: deleteItem)
                    }
                }

                Spacer()

                // Start Shopping Button
                Button(action: {
                    viewModel.saveGroceryList()
                    showShoppingView = true
                }) {
                    Text("Start Shopping")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .navigationDestination(isPresented: $showShoppingView) {
                    ShoppingView()
                }
            }
            .padding()
        }
    }

    private func addItem() {
        guard !viewModel.newGroceryItem.isEmpty else { return }
        viewModel.groceryList.append(viewModel.newGroceryItem)
        viewModel.newGroceryItem = ""
    }
    
    private func deleteItem(at offsets: IndexSet) {
        viewModel.groceryList.remove(atOffsets: offsets)
    }
}
