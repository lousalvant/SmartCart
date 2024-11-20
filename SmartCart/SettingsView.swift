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
    @Published var savedGroceryLists = [(id: String, storeName: String, budget: Double, groceryList: [String])]() // List of saved lists
    
    // Currency formatter
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencySymbol = "$"
        return formatter
    }()
    
    // Store options
    let storeOptions = ["ALDI", "Costco", "Publix", "The Fresh Market", "Walmart", "WholeFoods", "Winn-Dixie", "Other"]

    // Fetch saved grocery lists from Firebase
    func fetchSavedGroceryLists() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let collection = db.collection("users").document(userID).collection("groceryLists")

        collection.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching grocery lists: \(error.localizedDescription)")
                return
            }

            self?.savedGroceryLists = snapshot?.documents.compactMap { document in
                let data = document.data()
                let id = document.documentID
                let storeName = data["storeName"] as? String ?? ""
                let budget = data["budget"] as? Double ?? 0.0
                let groceryList = data["groceryList"] as? [String] ?? []
                return (id: id, storeName: storeName, budget: budget, groceryList: groceryList)
            } ?? []
        }
    }
    
    func loadGroceryList(_ list: (id: String, storeName: String, budget: Double, groceryList: [String])) {
        self.storeName = list.storeName
        self.budget = list.budget
        self.groceryList = list.groceryList
    }

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
    
    func clearGroceryList() {
        groceryList.removeAll()
    }
    
    // Reset function
        func reset() {
            storeName = "Select a Store"
            budget = nil
            groceryList.removeAll()
            newGroceryItem = ""
        }
}

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showShoppingView = false
    @State private var showSavedListsSheet = false // Control sheet presentation

    var body: some View {
        NavigationStack {
            ScrollView {
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

                        HStack {
                            Text("$") // Prefix text
                                .font(.headline)
                            TextField(
                                "Enter Budget",
                                text: Binding(
                                    get: {
                                        viewModel.budget != nil ? String(format: "%.2f", viewModel.budget!) : ""
                                    },
                                    set: { newValue in
                                        if let value = Double(newValue.filter { "0123456789.".contains($0) }) {
                                            viewModel.budget = value
                                        } else {
                                            viewModel.budget = nil
                                        }
                                    }
                                )
                            )
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }

                    // View Saved Lists Button
                    Button(action: {
                        showSavedListsSheet = true
                        viewModel.fetchSavedGroceryLists() // Fetch lists when the sheet is about to show
                    }) {
                        Text("View Saved Lists")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showSavedListsSheet) {
                        SavedListsView(viewModel: viewModel)
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
                        .frame(height: 200) // Restrict List height for better scrolling

                        Button(action: viewModel.clearGroceryList) {
                            Text("Clear List")
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
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
                .onAppear {
                    viewModel.reset() // Reset settings when view appears
                }
            }
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

// New SavedListsView to display saved grocery lists in a sheet
struct SavedListsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(viewModel.savedGroceryLists, id: \.id) { list in
                Button(action: {
                    viewModel.loadGroceryList(list)
                    dismiss() // Dismiss the sheet after selecting a list
                }) {
                    HStack {
                        Text(list.storeName)
                        Spacer()
                        Text(viewModel.currencyFormatter.string(from: NSNumber(value: list.budget)) ?? "$0.00")
                    }
                }
            }
            .navigationTitle("Saved Lists")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
