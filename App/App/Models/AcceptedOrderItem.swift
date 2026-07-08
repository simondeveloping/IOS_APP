//
//  AcceptedOrderItem.swift
//  App
//

import Foundation

struct AcceptedOrderItem: Identifiable {
    let id: Int
    let orderId: Int
    let createrId: Int
    let title: String
    let description: String
    let price: Double?
    let location: String
    let date: Date
    let createdAt: String?
    var createrName: String = "Unbekannt"
    let completionToken: String?
    let isCompleted: Bool
}
