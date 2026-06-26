//
//  MeineAuftraegeViewModel.swift
//  App
//
//  Created by Boromir on 26.06.26.
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
    let date: String
    let createdAt: String?
}

@MainActor
class MeineAuftraegeViewModel: ObservableObject {
    @Published var orders: [CombinedOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadOrders(for userId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let response1 = try await supabase
                .from("AcceptedOrder")
                .select()
                .or("creater_id.eq.\(userId),accepter_id.eq.\(userId)")
                .order("created_at", ascending: false)
                .execute()

            let acceptedOrders: [AcceptedOrder] = try JSONDecoder().decode([AcceptedOrder].self, from: response1.data)

            guard !acceptedOrders.isEmpty else {
                orders = []
                isLoading = false
                return
            }

            let orderIds = acceptedOrders.map { $0.order_id }
            let response2 = try await supabase
                .from("Order")
                .select()
                .in("id", values: orderIds)
                .execute()

            let orderItems: [OrderItem] = try JSONDecoder().decode([OrderItem].self, from: response2.data)

            let orderMap = Dictionary(uniqueKeysWithValues: orderItems.map { ($0.id, $0) })

            orders = acceptedOrders.compactMap { accepted in
                guard let order = orderMap[accepted.order_id] else { return nil }
                return CombinedOrder(
                    id: accepted.id,
                    orderId: accepted.order_id,
                    createrId: accepted.creater_id,
                    accepterId: accepted.accepter_id,
                    title: order.title,
                    description: order.description,
                    price: order.price,
                    location: order.location,
                    date: order.date,
                    createdAt: accepted.created_at
                )
            }
        } catch {
            print("Fehler beim Laden der Aufträge:", error)
            errorMessage = "Aufträge konnten nicht geladen werden"
        }
        isLoading = false
    }
}
