//
//  CategoryModel.swift
//  App
//
//  Created by Merry on 12.06.26.
//
import Foundation

struct Category: Identifiable, Decodable {
    let id: Int
    let title: String
    let imagePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imagePath = "image_path"
    }
}
