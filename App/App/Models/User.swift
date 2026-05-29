//
//  User.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation

struct User: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
}
