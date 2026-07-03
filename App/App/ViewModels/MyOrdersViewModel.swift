//
//  MyOrdersViewModel.swift
//  App
//
//  Created by Merry on 19.06.26.
//
import Foundation
import SwiftUI
import Combine
import Supabase

private struct MyOrdersAppUser: Decodable {
    let id: Int64
}

struct EditOrderDraft {
    var title: String
    var description: String
    var price: String
    var categoryId: Int?
    var location: String
    var date: Date
    var isFlexibleTime: Bool
    var notes: String
}

private struct UpdateOrderRequest: Encodable {
    let title: String
    let description: String
    let price: Double?
    let categoryId: Int?
    let location: String
    let date: String
    let isFlexibleTime: Bool
    let notes: String
}

@MainActor
class MyOrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showSuccessBanner = false

    func showBannerAndHide() {
        withAnimation {
            showSuccessBanner = true
        }
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation {
                showSuccessBanner = false
            }
        }
    }

    func fetchMyOrders() async {
        isLoading = true
        errorMessage = nil
        do {
            let session = try await supabase.auth.session
            let email = session.user.email ?? ""

            let appUser: MyOrdersAppUser = try await supabase
                .from("User")
                .select("id")
                .eq("email", value: email)
                .single()
                .execute()
                .value

            let result: [Order] = try await supabase
                .from("Order")
                .select()
                .eq("user_id", value: String(appUser.id))
                .order("date", ascending: false)
                .execute()
                .value

            orders = result
        } catch {
            print("Fehler beim Laden:", error)
            errorMessage = "Aufträge konnten nicht geladen werden."
        }
        isLoading = false
    }

    func loadCategories() async {
        do {
            categories = try await supabase
                .from("Category")
                .select("id, title, image_path")
                .order("title")
                .execute()
                .value
        } catch {
            print("Fehler beim Laden der Kategorien:", error)
            errorMessage = "Kategorien konnten nicht geladen werden."
        }
    }

    func updateOrder(_ order: Order, draft: EditOrderDraft) async -> Bool {
        guard !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Bitte gib einen Titel an."
            return false
        }

        isSaving = true
        errorMessage = nil

        let request = UpdateOrderRequest(
            title: draft.title,
            description: draft.description,
            price: Double(draft.price.replacingOccurrences(of: ",", with: ".")),
            categoryId: draft.categoryId,
            location: draft.location,
            date: Self.databaseDateFormatter.string(from: draft.date),
            isFlexibleTime: draft.isFlexibleTime,
            notes: draft.notes
        )

        do {
            try await supabase
                .from("Order")
                .update(request)
                .eq("id", value: String(order.id))
                .execute()

            await fetchMyOrders()
            isSaving = false
            return true
        } catch {
            print("Fehler beim Bearbeiten:", error)
            errorMessage = "Auftrag konnte nicht gespeichert werden."
            isSaving = false
            return false
        }
    }

    func deleteOrder(_ order: Order) async {
        do {
            try await supabase
                .from("Order")
                .delete()
                .eq("id", value: String(order.id))
                .execute()

            orders.removeAll { $0.id == order.id }
        } catch {
            print("Fehler beim Löschen:", error)
            errorMessage = "Auftrag konnte nicht gelöscht werden."
        }
    }

    private static let databaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
