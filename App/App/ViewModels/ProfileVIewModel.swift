//
//  ProfileVIewModel.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var averageRating: Double = 0
    @Published var ratingCount: Int = 0
    @Published var isLoadingRatings = false

    func loadRatings(for userId: Int) async {
        isLoadingRatings = true
        do {
            let response = try await supabase
                .from("Rating")
                .select()
                .eq("user_id", value: userId)
                .execute()

            let ratings: [Rating] = try JSONDecoder().decode([Rating].self, from: response.data)
            ratingCount = ratings.count
            if ratingCount > 0 {
                let total = ratings.reduce(0) { $0 + $1.stars }
                averageRating = Double(total) / Double(ratingCount)
            }
        } catch {
            print("Fehler beim Laden der Bewertungen:", error)
        }
        isLoadingRatings = false
    }
}
