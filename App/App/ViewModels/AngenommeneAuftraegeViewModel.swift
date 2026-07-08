import Foundation
import Supabase
import Combine
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
    let completionToken: String?   // neu
    let isCompleted: Bool          // neu
}
@MainActor
class AngenommeneAuftraegeViewModel: ObservableObject {
    @Published var orders: [AcceptedOrderItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadOrders(for userId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabase
                .from("AcceptedOrder")
                .select()
                .eq("accepter_id", value: userId)
                .order("created_at", ascending: false)
                .execute()

            let acceptedOrders: [AcceptedOrder] = try JSONDecoder().decode(
                [AcceptedOrder].self,
                from: response.data
            )

            let orderIds = acceptedOrders.map { $0.order_id }
            var orderMap: [Int: Order] = [:]

            if !orderIds.isEmpty {
                let orderResponse = try await supabase
                    .from("Order")
                    .select()
                    .in("id", values: orderIds)
                    .execute()

                let orderItems: [Order] = try JSONDecoder().decode(
                    [Order].self,
                    from: orderResponse.data
                )
                orderMap = Dictionary(orderItems.map { (Int($0.id), $0) }) { _, last in last }
            }

            var items: [AcceptedOrderItem] = acceptedOrders.compactMap { accepted in
                guard let order = orderMap[accepted.order_id] else { return nil }
                return AcceptedOrderItem(
                    id: accepted.id,
                    orderId: accepted.order_id,
                    createrId: accepted.creater_id,
                    title: order.title,
                    description: order.description,
                    price: order.price,
                    location: order.location,
                    date: order.date,
                    createdAt: accepted.created_at,
                    completionToken: accepted.completion_token,  // neu
                    isCompleted: accepted.is_completed ?? false   // neu
                )
            }

            let createrIds = Set(items.map { $0.createrId })
            var names: [Int: String] = [:]
            for id in createrIds {
                do {
                    let userResponse = try await supabase
                        .from("User")
                        .select()
                        .eq("id", value: id)
                        .single()
                        .execute()
                    let user: UserProfile = try JSONDecoder().decode(
                        UserProfile.self,
                        from: userResponse.data
                    )
                    names[id] = "\(user.Vorname) \(user.Nachname)"
                } catch {
                    print("Konnte Benutzer \(id) nicht laden:", error)
                }
            }

            for i in items.indices {
                if let name = names[items[i].createrId] {
                    items[i].createrName = name
                }
            }

            orders = items

        } catch {
            print("Fehler beim Laden der angenommenen Aufträge:", error)
            errorMessage = "Aufträge konnten nicht geladen werden"
        }
        isLoading = false
    }
}
