//
//  OrderDetailModel.swift
//  App
//
//  Created by Merry on 26.06.26.
//
struct AcceptedOrderPayload: Encodable {
    let orderId: Int
    let createrId: Int
    let accepterId: Int
    let completionToken: String

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case createrId = "creater_id"
        case accepterId = "accepter_id"
        case completionToken = "completion_token"
    }
}
