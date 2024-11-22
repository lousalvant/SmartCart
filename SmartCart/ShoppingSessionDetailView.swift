//
//  ShoppingSessionDetailView.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/22/24.
//

import SwiftUI

struct ShoppingSessionDetailView: View {
    let session: ShoppingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Store: \(session.store)")
                .font(.title2)
                .padding(.horizontal)

            Text("Date: \(session.date.formatted(date: .abbreviated, time: .omitted))")
                .padding(.horizontal)

            Divider()

            Text("Items")
                .font(.headline)
                .padding(.horizontal)

            List(session.items, id: \.name) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("Qty: \(item.quantity)")
                    Spacer()
                    Text("\(String(format: "$%.2f", item.price))")
                }
            }
            .listStyle(InsetGroupedListStyle())

            Spacer()

            Text("Total: \(String(format: "$%.2f", session.estimatedTotal))")
                .font(.title3)
                .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
