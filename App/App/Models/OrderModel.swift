//
//  Order.swift
//  App
//
//  Created by Boromir on 05.06.26.
//

import Foundation

struct AcceptedOrder: Codable, Identifiable {
    let id: Int
    let order_id: Int
    let creater_id: Int
    let accepter_id: Int
    let created_at: String?
}

struct OrderItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let price: Double?
    let categoryId: Int?
    let location: String
    let date: String
    let isFlexibleTime: Bool
    let notes: String?
    let created_at: String?
}

