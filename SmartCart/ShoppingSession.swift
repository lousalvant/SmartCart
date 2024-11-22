//
//  ShoppingSession.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/22/24.
//

import Foundation
import FirebaseFirestore

struct ShoppingSession: Codable, Identifiable {
    let id: String
    let store: String
    let date: Date
    let items: [CartItem]
    let subtotal: Double
    let salesTax: Double
    let estimatedTotal: Double

    struct CartItem: Codable {
        let name: String
        let quantity: Int
        let price: Double
    }
}

// Extension to conform to Codable for Firestore compatibility
extension ShoppingSession {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        store = try container.decode(String.self, forKey: .store)
        date = try container.decode(Timestamp.self, forKey: .date).dateValue()
        items = try container.decode([CartItem].self, forKey: .items)
        subtotal = try container.decode(Double.self, forKey: .subtotal)
        salesTax = try container.decode(Double.self, forKey: .salesTax)
        estimatedTotal = try container.decode(Double.self, forKey: .estimatedTotal)
    }
}
