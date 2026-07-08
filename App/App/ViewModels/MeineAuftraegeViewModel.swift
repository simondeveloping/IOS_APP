//
//  MeineAuftraegeViewModel.swift
//  App
//
//  Created by Boromir on 26.06.26.
//

import Foundation
import Supabase
import Combine


@MainActor
class MeineAuftraegeViewModel: ObservableObject {
    @Published var orders: [CombinedOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var accepterNames: [Int: String] = [:]

    func loadOrders(for userId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            async let acceptedTask = supabase
                .from("AcceptedOrder")
                .select()
                .or("creater_id.eq.\(userId),accepter_id.eq.\(userId)")
                .order("created_at", ascending: false)
                .execute()

            async let ownOrdersTask = supabase
                .from("Order")
                .select()
                .eq("user_id", value: String(userId))
                .order("date", ascending: false)
                .execute()

            let (response1, ownOrdersResponse) = try await (acceptedTask, ownOrdersTask)

            let acceptedOrders: [AcceptedOrder] = try JSONDecoder().decode([AcceptedOrder].self, from: response1.data)
            let ownOrders: [Order] = try JSONDecoder().decode([Order].self, from: ownOrdersResponse.data)

            let acceptedOrderIds = Set(acceptedOrders.map { $0.order_id })

            let orderIds = acceptedOrders.map { $0.order_id }
            var orderMap: [Int: Order] = [:]

            if !orderIds.isEmpty {
                let response2 = try await supabase
                    .from("Order")
                    .select()
                    .in("id", values: orderIds)
                    .execute()

                let orderItems: [Order] = try JSONDecoder().decode([Order].self, from: response2.data)
                orderMap = Dictionary(uniqueKeysWithValues: orderItems.map { (Int($0.id), $0) })
            }

            var combined: [CombinedOrder] = acceptedOrders.compactMap { accepted in
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

            let existingOrderIds = Set(combined.map { $0.orderId })
            for order in ownOrders {
                guard !existingOrderIds.contains(Int(order.id)),
                      !acceptedOrderIds.contains(Int(order.id)) else { continue }
                combined.append(CombinedOrder(
                    id: Int(order.id) * -1,
                    orderId: Int(order.id),
                    createrId: userId,
                    accepterId: 0,
                    title: order.title,
                    description: order.description,
                    price: order.price,
                    location: order.location,
                    date: order.date,
                    createdAt: nil
                ))
            }

            orders = combined.sorted { $0.date > $1.date }

            // Für eigene, noch nicht angenommene Aufträge: den (einen) Chatpartner
            // ermitteln, falls dort schon jemand angeschrieben hat.
            let openOwnOrderIds = orders
                .filter { $0.createrId == userId && $0.accepterId == 0 }
                .map { $0.orderId }

            var chatPartnerMap: [Int: Int] = [:]

            if !openOwnOrderIds.isEmpty {
                let messageResponse = try await supabase
                    .from("Message")
                    .select()
                    .in("order_id", values: openOwnOrderIds)
                    .eq("receiver_id", value: userId)
                    .order("created_at", ascending: true)
                    .execute()

                let openOrderMessages: [Message] = try JSONDecoder().decode(
                    [Message].self,
                    from: messageResponse.data
                )

                // Ersten Absender pro Auftrag als Chatpartner nehmen (einfache Lösung,
                // kein Support für mehrere gleichzeitige Interessenten pro Auftrag).
                for message in openOrderMessages {
                    if chatPartnerMap[message.order_id] == nil {
                        chatPartnerMap[message.order_id] = message.sender_id
                    }
                }

                for i in orders.indices {
                    if let partnerId = chatPartnerMap[orders[i].orderId] {
                        orders[i].chatPartnerId = partnerId
                    }
                }
            }

            var userIds = Set(combined.flatMap { [$0.createrId, $0.accepterId] })
            userIds.formUnion(chatPartnerMap.values)
            userIds = userIds.filter { $0 != 0 }

            for id in userIds {
                do {
                    let userResponse = try await supabase
                        .from("User")
                        .select()
                        .eq("id", value: id)
                        .single()
                        .execute()
                    let user: UserProfile = try JSONDecoder().decode(UserProfile.self, from: userResponse.data)
                    accepterNames[id] = "\(user.Vorname) \(user.Nachname)"
                } catch {
                    print("Konnte Benutzer \(id) nicht laden:", error)
                }
            }

            for i in orders.indices {
                if orders[i].chatPartnerId != 0 {
                    orders[i].chatPartnerName = accepterNames[orders[i].chatPartnerId] ?? "Unbekannt"
                }
            }

            await loadUnreadCounts(for: userId)
        } catch {
            print("Fehler beim Laden der Aufträge:", error)
            errorMessage = "Aufträge konnten nicht geladen werden"
        }
        isLoading = false
    }

    func name(for userId: Int) -> String {
        accepterNames[userId] ?? "Unbekannt"
    }

    func loadUnreadCounts(for userId: Int) async {
        do {
            let response = try await supabase
                .from("Message")
                .select()
                .eq("receiver_id", value: userId)
                .execute()

            let allMessages: [Message] = try JSONDecoder().decode([Message].self, from: response.data)
            var counts: [Int: Int] = [:]
            for msg in allMessages {
                counts[msg.order_id, default: 0] += 1
            }

            for i in orders.indices {
                let orderId = orders[i].orderId
                if let count = counts[orderId] {
                    orders[i].unreadCount = count
                }
            }
        } catch {
            print("Fehler beim Laden der Nachrichtenanzahl:", error)
        }
    }
}
