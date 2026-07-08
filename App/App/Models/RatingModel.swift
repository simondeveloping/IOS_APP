//
//  RatingModel.swift
//  App
//
//  Created by Boromir on 19.06.26.
//

import Foundation

struct Rating: Identifiable, Decodable {
    let id: Int
    let description: String
    let stars: Int
    let title: String
    let user_id: Int
    let fromUser_id: Int
}

struct RatingPayload: Encodable {
    let description: String
    let stars: Int
    let title: String
    let user_id: Int
    let fromUser_id: Int
}
