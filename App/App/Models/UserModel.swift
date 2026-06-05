//
//  User.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation

struct User: Identifiable {
    let id = UUID()
    let email: String
    let vorname: String
    let nachname: String
}
