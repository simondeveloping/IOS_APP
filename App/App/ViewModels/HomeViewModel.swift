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

private struct AcceptedOrderRequest: Encodable {
    let created_at: String
    let order_id: Int64
    let creator_id: Int64
    let accepter_id: Int64
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
    func loadHomeData(userId : Int) async {
        isLoading = true
        errorMessage = nil

        await loadCategories()
        await loadRecommendations(userId : userId)

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

    private func loadRecommendations(userId : Int) async {
        do {
            let acceptedIds = (try? await OrderFilter.acceptedOrderIds()) ?? []
            
            let allOrders: [Order] = try await supabase
                .from("Order")
                .select()
                .order("date", ascending: true)
                .limit(20)
                .execute()
                .value

            // Eigene Aufträge ausblenden, weil man sie nicht selbst annehmen soll
            recommendations = allOrders
                .filter { $0.userId != userId && !acceptedIds.contains(Int($0.id)) }
                .prefix(12)
                .map { $0 }
        } catch {
            print("Fehler beim Laden der Empfehlungen:", error)
            errorMessage = "Empfehlungen konnten nicht geladen werden."
        }
    }
}
