//
//  HomeViewModel.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation
import Combine
import Supabase

private struct HomeAppUser: Decodable {
    let id: Int64
}

@MainActor
class HomeViewModel: ObservableObject {
    // Daten für die HomeView
    @Published var categories: [Category] = []
    @Published var recommendations: [Order] = []
    @Published var selectedCategoryId: Int?

    // Lade- und Fehlerstatus
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Empfehlungen nach ausgewählter Kategorie filtern
    var filteredRecommendations: [Order] {
        guard let selectedCategoryId else { return recommendations }
        return recommendations.filter { $0.categoryId == Int64(selectedCategoryId) }
    }

    // Kategorien und Aufträge laden
    func loadHomeData() async {
        isLoading = true
        errorMessage = nil

        await loadCategories()
        await loadRecommendations()

        isLoading = false
    }

    // Kategorie auswählen oder wieder abwählen
    func toggleCategory(_ category: Category) {
        selectedCategoryId = selectedCategoryId == category.id ? nil : category.id
    }

    private func loadCategories() async {
        do {
            categories = try await supabase
                .from("Category")
                .select("id, title")
                .order("title")
                .execute()
                .value
        } catch {
            print("Fehler beim Laden der Kategorien:", error)
            errorMessage = "Kategorien konnten nicht geladen werden."
        }
    }

    private func loadRecommendations() async {
        do {
            let currentUserId = await currentAppUserId()
            let allOrders: [Order] = try await supabase
                .from("Order")
                .select()
                .order("date", ascending: true)
                .limit(20)
                .execute()
                .value

            // Eigene Aufträge ausblenden, weil man sie nicht selbst annehmen soll
            recommendations = allOrders
                .filter { currentUserId == nil || $0.userId != currentUserId }
                .prefix(12)
                .map { $0 }
        } catch {
            print("Fehler beim Laden der Empfehlungen:", error)
            errorMessage = "Empfehlungen konnten nicht geladen werden."
        }
    }

    // Eigene User-ID laden, damit eigene Aufträge nicht empfohlen werden
    private func currentAppUserId() async -> Int64? {
        do {
            let session = try await supabase.auth.session
            guard let email = session.user.email else { return nil }

            let appUser: HomeAppUser = try await supabase
                .from("User")
                .select("id")
                .eq("email", value: email)
                .single()
                .execute()
                .value

            return appUser.id
        } catch {
            print("Fehler beim Laden des aktuellen Users:", error)
            return nil
        }
    }
}
