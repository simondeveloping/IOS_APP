import Foundation

struct Message: Codable, Identifiable {
    let id: Int?
    let order_id: Int
    let sender_id: Int
    let receiver_id: Int
    let message: String
    let created_at: String?
}

struct SendMessagePayload: Encodable {
    let order_id: Int
    let sender_id: Int
    let receiver_id: Int
    let message: String
}
