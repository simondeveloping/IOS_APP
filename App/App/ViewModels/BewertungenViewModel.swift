//
//  BewertungenViewModel.swift
//  App
//

import Foundation
import SwiftUI
import Supabase
import Combine

@MainActor
class BewertungenViewModel: ObservableObject {
    @Published var ratings: [Rating] = []
    @Published var fromUserNames: [Int: String] = [:]
    @Published var isLoading = false

    func loadRatings(for userId: Int) async {
        isLoading = true
        do {
            let response = try await supabase
                .from("Rating")
                .select()
                .eq("user_id", value: userId)
                .order("id", ascending: false)
                .execute()

            ratings = try JSONDecoder().decode([Rating].self, from: response.data)

            let uniqueUserIds = Set(ratings.map { $0.fromUser_id })
            for fromUserId in uniqueUserIds {
                do {
                    let userResponse = try await supabase
                        .from("User")
                        .select()
                        .eq("id", value: fromUserId)
                        .single()
                        .execute()

                    let user: UserProfile = try JSONDecoder().decode(UserProfile.self, from: userResponse.data)
                    fromUserNames[fromUserId] = "\(user.Vorname) \(user.Nachname)"
                } catch {
                    print("Konnte Benutzer \(fromUserId) nicht laden:", error)
                }
            }
        } catch {
            print("Fehler beim Laden der Bewertungen:", error)
        }
        isLoading = false
    }

    func name(for userId: Int) -> String {
        fromUserNames[userId] ?? "Unbekannt"
    }
}
