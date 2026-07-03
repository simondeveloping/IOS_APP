//
//  OrderFilter.swift
//  App
//
//  Created by Merry on 03.07.26.
//
import Supabase

struct OrderFilter {
    static func acceptedOrderIds() async throws -> [Int] {
        struct AcceptedOrderId: Decodable {
            let orderId: Int
            enum CodingKeys: String, CodingKey {
                case orderId = "order_id"
            }
        }

        let accepted: [AcceptedOrderId] = try await supabase
            .from("AcceptedOrder")
            .select("order_id")
            .execute()
            .value

        return accepted.map { $0.orderId }
    }

    static func filterAccepted(from orders: [Order], acceptedIds: [Int]) -> [Order] {
        guard !acceptedIds.isEmpty else { return orders }
        return orders.filter { !acceptedIds.contains(Int($0.id)) }
    }
}
