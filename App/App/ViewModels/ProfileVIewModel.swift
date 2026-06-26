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

    @Published var profile: UserProfile?
    @Published var isLoadingProfile = false
    @Published var isSaving = false
    @Published var saveSuccess = false
    @Published var errorMessage: String?

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

    func loadProfile(for userId: Int) async {
        isLoadingProfile = true
        errorMessage = nil
        do {
            let response = try await supabase
                .from("User")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()

            let userProfile: UserProfile = try JSONDecoder().decode(UserProfile.self, from: response.data)
            profile = userProfile
        } catch {
            print("Fehler beim Laden des Profils:", error)
            errorMessage = "Profil konnte nicht geladen werden"
        }
        isLoadingProfile = false
    }

    func updateProfile(vorname: String, nachname: String, email: String, userId: Int) async {
        isSaving = true
        saveSuccess = false
        errorMessage = nil
        do {
            try await supabase
                .from("User")
                .update(["Vorname": vorname, "Nachname": nachname, "email": email])
                .eq("id", value: userId)
                .execute()

            UserDefaults.standard.set(vorname, forKey: "userVorname")
            UserDefaults.standard.set(nachname, forKey: "userNachname")

            profile = UserProfile(id: userId, email: email, Vorname: vorname, Nachname: nachname)
            saveSuccess = true
        } catch {
            print("Fehler beim Speichern des Profils:", error)
            errorMessage = "Profil konnte nicht gespeichert werden"
        }
        isSaving = false
    }
}
