//
//  Order.swift
//  App
//
//  Created by Boromir on 05.06.26.
//

import Foundation

struct AcceptedOrder: Codable, Identifiable {
    let id: Int
    let order_id: Int
    let creater_id: Int
    let accepter_id: Int
    let created_at: String?
}


struct Order: Decodable, Identifiable {
    let id: Int64
    let title: String
    let description: String
    let price: Double?
    let categoryId: Int64?
    let location: String
    let date: Date
    let isFlexibleTime: Bool
    let notes: String
    let userId: Int64

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, location, date, notes
        case categoryId = "category_id"
        case categoryIdCamel = "categoryId"
        case isFlexibleTime = "is_flexible_time"
        case isFlexibleTimeCamel = "isFlexibleTime"
        case userId = "user_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        categoryId = try container.decodeIfPresent(Int64.self, forKey: .categoryId)
            ?? container.decodeIfPresent(Int64.self, forKey: .categoryIdCamel)
        location = try container.decode(String.self, forKey: .location)
        isFlexibleTime = try container.decodeIfPresent(Bool.self, forKey: .isFlexibleTime)
            ?? container.decodeIfPresent(Bool.self, forKey: .isFlexibleTimeCamel)
            ?? false
        notes = try container.decode(String.self, forKey: .notes)
        userId = try container.decode(Int64.self, forKey: .userId)

        let dateString = try container.decode(String.self, forKey: .date)
        guard let parsedDate = Self.parseDate(dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        date = parsedDate
    }

    private static func parseDate(_ value: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: value) {
            return date
        }

        return ISO8601DateFormatter().date(from: value)
    }
}
