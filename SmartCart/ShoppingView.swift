//
//  ShoppingView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import CoreLocation

struct ShoppingView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel // Access SettingsViewModel
    @State private var cartItems: [(name: String, price: Double)] = [] // Track items in the cart with price
    @State private var showItemEntrySheet = false // Show sheet for manual item entry
    @State private var showCartSummary = false // Control navigation to CartSummaryView
    @State private var showScanner = false // Show scanner sheet
    
    // Location and Tax Information
    @State private var cityState = "Unknown Location"
    @State private var taxRate: Double = 0.0
    @StateObject private var locationManagerDelegate = LocationManagerDelegate()
    
    @State private var showGroceryListSheet = false
    
    // Alert State
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Subtotal, Sales Tax, and Estimated Total
    private var subtotal: Double {
        cartItems.reduce(0) { $0 + $1.price }
    }
    private var salesTax: Double {
        subtotal * taxRate
    }
    private var estimatedTotal: Double {
        subtotal + salesTax
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Location, Tax Rate, and Store at the top
                VStack(alignment: .leading, spacing: 10) {
                    Text("Location: \(cityState)")
                        .font(.headline)
                    Text("Sales Tax: \(String(format: "%.2f", taxRate))%")
                        .font(.headline)
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
                    
                    // Subtotal, Sales Tax, and Estimated Total
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Subtotal:")
                            Spacer()
                            Text(settingsViewModel.currencyFormatter.string(from: NSNumber(value: subtotal)) ?? "$0.00")
                        }
                        HStack {
                            Text("Sales Tax:")
                            Spacer()
                            Text(settingsViewModel.currencyFormatter.string(from: NSNumber(value: salesTax)) ?? "$0.00")
                        }
                        HStack {
                            Text("Est. Total:")
                                .bold()
                            Spacer()
                            Text(settingsViewModel.currencyFormatter.string(from: NSNumber(value: estimatedTotal)) ?? "$0.00")
                                .bold()
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 10) {
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
                        
                        // Scan item button
                        Button(action: {
                            showScanner = true
                        }) {
                            Text("Scan Item")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                        
                        // View list button
                        Button(action: {
                            showGroceryListSheet = true
                        }) {
                            Text("View List")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showItemEntrySheet) {
                        ItemEntryView { itemName, itemPrice in
                            addItem(name: itemName, price: itemPrice)
                        }
                    }
                    .sheet(isPresented: $showScanner) {
                        ScannerView { result in
                            switch result {
                            case .success(let scannedData):
                                parseScannedData(scannedData)
                            case .failure(let error):
                                print("Scanning failed: \(error.localizedDescription)")
                            }
                        }
                    }
                    .sheet(isPresented: $showGroceryListSheet) {
                        ViewGroceryListSheet(groceryList: settingsViewModel.groceryList)
                    }
                }

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
                    CartSummaryView(
                        store: settingsViewModel.storeName,
                        cartItems: cartItems,
                        subtotal: subtotal,
                        salesTax: salesTax,
                        estimatedTotal: estimatedTotal
                    )
                }
            }
            .navigationTitle("Shopping Session")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                configureLocationManager()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Budget Exceeded!"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // Add new item to the cart
    private func addItem(name: String, price: Double) {
        cartItems.append((name: name, price: price))
        
        if let budget = settingsViewModel.budget {
            print("Budget: \(budget)") // Debugging
            print("Estimated Total: \(estimatedTotal)") // Debugging
            
            if estimatedTotal > budget {
                alertMessage = "Your total has exceeded your budget of \(settingsViewModel.currencyFormatter.string(from: NSNumber(value: budget)) ?? "$0.00")."
                print("Budget Exceeded!") // Debugging
                DispatchQueue.main.async {
                    showAlert = true
                }
            }
        } else {
            print("Budget not set. Skipping budget check.") // Debugging
        }
    }

    // Delete item from the cart
    private func deleteItem(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }

    // Parse scanned data
    private func parseScannedData(_ scannedData: [String]) {
        print("Scanned Data: \(scannedData)") // Debugging

        for (index, line) in scannedData.enumerated() {
            if let priceMatch = line.range(of: "\\$?\\d+(\\.\\d{2})?", options: .regularExpression) {
                let priceString = String(line[priceMatch]).replacingOccurrences(of: "$", with: "")
                let itemName = (index + 1 < scannedData.count) ? scannedData[index + 1].trimmingCharacters(in: .whitespacesAndNewlines) : "Unknown Item"
                
                if let price = Double(priceString) {
                    addItem(name: itemName, price: price)
                    return
                }
            }
        }
    }

    // Configure CLLocationManager
        private func configureLocationManager() {
            locationManagerDelegate.onLocationUpdate = { location in
                print("Received location: \(location.coordinate.latitude), \(location.coordinate.longitude)") // Debugging
                self.getZipCode(from: location) { zipCode in
                    guard let zipCode = zipCode else {
                        print("Failed to retrieve ZIP code.")
                        return
                    }
                    print("ZIP Code: \(zipCode)") // Debugging
                    self.fetchTaxRate(by: zipCode)
                }
            }
            locationManagerDelegate.startUpdatingLocation()
        }

        private func getZipCode(from location: CLLocation, completion: @escaping (String?) -> Void) {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Failed to get ZIP code: \(error.localizedDescription)")
                    completion(nil)
                } else if let placemark = placemarks?.first, let postalCode = placemark.postalCode {
                    print("Retrieved ZIP code: \(postalCode)") // Debugging
                    completion(postalCode)
                } else {
                    print("No postal code found.")
                    completion(nil)
                }
            }
        }

    private func fetchTaxRate(by zipCode: String) {
        let urlString = "https://retrieveustaxrate.p.rapidapi.com/GetTaxRateByZip?zip=\(zipCode)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("38672978a3mshb0e70ee4a14db29p110155jsnb9b1f54aa483", forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("retrieveustaxrate.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("Basic Ym9sZGNoYXQ6TGZYfm0zY2d1QzkuKz9SLw==", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching tax rate: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let city = json["City"] as? String,
                   let state = json["State"] as? String,
                   let taxRate = json["TaxRate"] as? Double {
                    DispatchQueue.main.async {
                        self.cityState = "\(city), \(state)"
                        self.taxRate = taxRate
                    }
                } else {
                    print("Unexpected JSON format or missing data.")
                }
            } catch {
                print("Failed to decode tax rate: \(error)")
            }
        }.resume()
    }
}

    class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
        var onLocationUpdate: ((CLLocation) -> Void)?
        private var locationManager = CLLocationManager()

        override init() {
            super.init()
            locationManager.delegate = self
        }

        func startUpdatingLocation() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                onLocationUpdate?(location)
                locationManager.stopUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager error: \(error.localizedDescription)")
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

struct ViewGroceryListSheet: View {
    @Environment(\.dismiss) var dismiss
    let groceryList: [String] // Local copy of the grocery list

    var body: some View {
        NavigationView {
            List(groceryList, id: \.self) { item in
                Text(item) // Display each item
            }
            .navigationTitle("Your Grocery List")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss handled by the sheet's environment
                        dismiss()
                    }
                }
            }
        }
    }
}

extension Double {
    /// Rounds the double to the specified number of decimal places.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
