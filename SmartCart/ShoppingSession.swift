//
//  ShoppingSession.swift
//  SmartCart
//
//  Created by Lou-Michael Salvant on 11/22/24.
//

import Foundation

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
