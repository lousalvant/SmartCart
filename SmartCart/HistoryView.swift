//
//  HistoryView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/9/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HistoryView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel // Access SettingsViewModel
    @State private var shoppingSessions: [ShoppingSession] = [] // Store fetched shopping sessions
    @State private var totalWeek: Double = 0.0
    @State private var totalMonth: Double = 0.0
    @State private var totalYear: Double = 0.0
    @State private var selectedSession: ShoppingSession? // Selected session to view details

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Spending Overview")
                    .font(.title)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("This Week: \(settingsViewModel.currencyFormatter.string(from: NSNumber(value: totalWeek)) ?? "$0.00")")
                    Text("This Month: \(settingsViewModel.currencyFormatter.string(from: NSNumber(value: totalMonth)) ?? "$0.00")")
                    Text("This Year: \(settingsViewModel.currencyFormatter.string(from: NSNumber(value: totalYear)) ?? "$0.00")")
                }
                .padding(.horizontal)

                Divider()

                Text("Shopping Sessions")
                    .font(.headline)
                    .padding(.horizontal)

                List(shoppingSessions) { session in
                    NavigationLink(destination: ShoppingSessionDetailView(session: session)) {
                        VStack(alignment: .leading) {
                            Text(session.store)
                                .font(.headline)
                            Text("Date: \(session.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                            Text("Total: \(settingsViewModel.currencyFormatter.string(from: NSNumber(value: session.estimatedTotal)) ?? "$0.00")")
                                .font(.subheadline)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                Spacer()
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchShoppingSessions()
            }
        }
    }

    // Fetch shopping sessions from Firestore
    private func fetchShoppingSessions() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let collection = db.collection("users").document(userID).collection("shoppingSessions")

        collection.order(by: "date", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching sessions: \(error.localizedDescription)")
                return
            }

            shoppingSessions = snapshot?.documents.compactMap { document in
                try? document.data(as: ShoppingSession.self)
            } ?? []

            calculateTotals()
        }
    }

    // Calculate total spending
    private func calculateTotals() {
        let calendar = Calendar.current
        let now = Date()

        totalWeek = shoppingSessions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.estimatedTotal }

        totalMonth = shoppingSessions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.estimatedTotal }

        totalYear = shoppingSessions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
            .reduce(0) { $0 + $1.estimatedTotal }
    }
}
