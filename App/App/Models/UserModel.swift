//
//  User.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation

struct UserProfile: Encodable, Decodable {
    let id: Int?
    let email: String
    let Vorname: String
    let Nachname: String
}
