//
//  ErstellenModel.swift
//  App
//
//  Created by Merry on 12.06.26.
//
import Foundation

struct CreateJobRequest: Codable {
    var title: String
    var description: String
    var price: Double?
    var categoryId: Int?
    var location: String
    var date: Date
    var isFlexibleTime: Bool
    var notes: String
    var user_id: Int
}
