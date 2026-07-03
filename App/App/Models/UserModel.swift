//
//  User.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation

struct UserProfile: Encodable, Decodable ,Equatable{
    let id: Int?
    let email: String
    let Vorname: String
    let Nachname: String
    var avatar: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, email, Vorname, Nachname
        case avatar = "Avatar"
    }
}
