//
//  CombinedOrder.swift
//  App
//
//  Created by Boromir on 03.07.26.
//
import Foundation
import Supabase
import Combine

struct CombinedOrder: Identifiable {
    let id: Int
    let orderId: Int
    let createrId: Int
    let accepterId: Int
    let title: String
    let description: String
    let price: Double?
    let location: String
    let date: Date
    let createdAt: String?
    var unreadCount: Int = 0
    var accepterName: String = "Unbekannt"
    var chatPartnerId: Int = 0
    var chatPartnerName: String = ""
    var isCompleted: Bool = false
}
