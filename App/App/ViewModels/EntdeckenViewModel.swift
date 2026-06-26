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
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

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
