//
//  EntdeckenViewModel.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation
import Supabase
import Combine

@MainActor
class EntdeckenViewModel: ObservableObject {
    @Published var allOrders: [Order] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var sellerNames: [Int64: String] = [:]
    @Published var sellerRatings: [Int64: Double] = [:]

    private var currentUserId: Int64?

    var filteredOrders: [Order] {
        if searchText.isEmpty {
            return allOrders
        }
        return allOrders.filter { order in
            order.title.localizedCaseInsensitiveContains(searchText) ||
            order.description.localizedCaseInsensitiveContains(searchText) ||
            order.location.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadOrders() async {
        isLoading = true
        errorMessage = nil

        await loadCurrentUserId()
        await fetchOrders()
        await loadCategories()
        await loadSellerNames()
        await loadSellerRatings()

        isLoading = false
    }

    private func loadCurrentUserId() async {
        do {
            let session = try await supabase.auth.session
            guard let email = session.user.email else {
                currentUserId = nil
                return
            }

            let appUser: [HomeAppUser] = try await supabase
                .from("User")
                .select("id")
                .eq("email", value: email)
                .execute()
                .value

            currentUserId = appUser.first?.id
        } catch {
            print("Fehler beim Laden des Users:", error)
            currentUserId = nil
        }
    }

    func categoryName(for order: Order) -> String {
        guard let categoryId = order.categoryId else { return "Keine Kategorie" }
        return categories.first { $0.id == Int(categoryId) }?.title ?? "Keine Kategorie"
    }

    private func loadCategories() async {
        do {
            categories = try await supabase
                .from("Category")
                .select("id, title, image_path")
                .order("title")
                .execute()
                .value
        } catch {
            print("Fehler beim Laden der Kategorien:", error)
        }
    }

    private func loadSellerNames() async {
        let userIds = Set(allOrders.map { $0.userId })
        for id in userIds {
            do {
                let user: UserProfile = try await supabase
                    .from("User")
                    .select()
                    .eq("id", value: Int(id))
                    .single()
                    .execute()
                    .value
                sellerNames[id] = "\(user.Vorname) \(user.Nachname)"
            } catch {
                print("Fehler beim Laden des Verkäufernamens für \(id):", error)
                sellerNames[id] = "Unbekannt"
            }
        }
    }

    private func loadSellerRatings() async {
        let userIds = Set(allOrders.map { $0.userId })
        for id in userIds {
            do {
                let ratings: [Rating] = try await supabase
                    .from("Rating")
                    .select()
                    .eq("user_id", value: Int(id))
                    .execute()
                    .value
                if !ratings.isEmpty {
                    let total = ratings.reduce(0) { $0 + $1.stars }
                    sellerRatings[id] = Double(total) / Double(ratings.count)
                }
            } catch {
                print("Fehler beim Laden der Bewertungen für \(id):", error)
            }
        }
    }

    private func fetchOrders() async {
        do {
            let orders: [Order] = try await supabase
                .from("Order")
                .select()
                .order("date", ascending: false)
                .limit(50)
                .execute()
                .value

            if let currentUserId {
                allOrders = orders.filter { $0.userId != currentUserId }
            } else {
                allOrders = orders
            }

            if allOrders.isEmpty {
                print("Keine Aufträge gefunden. Geladene Orders: \(orders.count), currentUserId: \(currentUserId ?? 0)")
            }
        } catch {
            print("Fehler beim Laden der Aufträge:", error)
            errorMessage = "Aufträge konnten nicht geladen werden."
        }
    }
}

private struct HomeAppUser: Decodable {
    let id: Int64
}
