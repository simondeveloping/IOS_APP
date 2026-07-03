//
//  FavoritenViewModel.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class FavoritenViewModel: ObservableObject {
    @Published var favoriteOrders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @AppStorage("userId") var userId: Int = 0
    
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil

        do {
            // Alle Favoriten des Users holen
            let favorites: [Favorite] = try await supabase
                .from("Favorites")
                .select()
                .eq("user_id", value: Int(userId))
                .execute()
                .value

            // Aus den Favoriten die Order-IDs extrahieren
            let orderIds = favorites.map { Int($0.orderId) }

            guard !orderIds.isEmpty else {
                favoriteOrders = []
                isLoading = false
                return
            }

            // Die zugehörigen Aufträge laden
            let orders: [Order] = try await supabase
                .from("Order")
                .select()
                .in("id", values: orderIds)
                .execute()
                .value

            favoriteOrders = orders

        } catch {
            print("Fehler beim Laden der Favoriten:", error)
            errorMessage = "Favoriten konnten nicht geladen werden."
        }

        isLoading = false
    }
}
