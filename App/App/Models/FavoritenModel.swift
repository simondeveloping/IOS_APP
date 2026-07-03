//
//  FavoritenModel.swift
//  App
//
//  Created by Merry on 26.06.26.
//
struct Favorite: Decodable {
    let id: Int64
    let userId: Int64
    let orderId: Int64

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case orderId = "order_id"
    }
}

struct FavoritePayload: Encodable {
    let userId: Int
    let orderId: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case orderId = "order_id"
    }
}
