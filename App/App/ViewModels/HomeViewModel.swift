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
    let id: Int
}

private struct AcceptedOrderRequest: Encodable {
    let created_at: String
    let order_id: Int
    let creator_id: Int
    let accepter_id: Int
}

@MainActor
class HomeViewModel: ObservableObject {
    // Daten für die HomeView
    @Published var categories: [Category] = []
    @Published var recommendations: [Order] = []
    @Published var selectedCategoryId: Int?
    @Published var sellerNames: [Int: String] = [:]
    @Published var sellerRatings: [Int: Double] = [:]

    // Lade- und Fehlerstatus
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userAvatarPath: String?

    // Hält den aktuell laufenden Ladevorgang, damit sich .task und .refreshable
    // nicht gegenseitig überschneiden und in CancellationErrors laufen.
    private var currentLoadTask: Task<Void, Never>?

    // Empfehlungen nach ausgewählter Kategorie filtern
    var filteredRecommendations: [Order] {
        guard let selectedCategoryId else { return recommendations }
        return recommendations.filter { $0.categoryId == selectedCategoryId }
    }

    // Kategorien und Aufträge laden
    // Bricht einen eventuell noch laufenden Ladevorgang zuerst ab,
    // damit niemals zwei Ladevorgänge gleichzeitig laufen.
    func loadHomeData(userId: Int) async {
        currentLoadTask?.cancel()

        let task = Task {
            await performLoad(userId: userId)
        }
        currentLoadTask = task
        await task.value
    }

    private func performLoad(userId: Int) async {
        isLoading = true
        errorMessage = nil

        // Diese beiden sind unabhängig voneinander -> können parallel laufen
        async let avatarTask: () = loadCurrentUserAvatar()
        async let categoriesTask: () = loadCategories()

        await avatarTask
        await categoriesTask

        guard !Task.isCancelled else {
            isLoading = false
            return
        }

        // WICHTIG: Empfehlungen MÜSSEN zuerst geladen werden,
        // da loadSellerNames/loadSellerRatings von `recommendations` abhängen.
        await loadRecommendations(userId: userId)

        guard !Task.isCancelled else {
            isLoading = false
            return
        }

        async let namesTask: () = loadSellerNames()
        async let ratingsTask: () = loadSellerRatings()
        await namesTask
        await ratingsTask

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
                .select("id, title, image_path")
                .order("title")
                .execute()
                .value
        } catch is CancellationError {
            // Ladevorgang wurde bewusst abgebrochen (z.B. neuer Refresh) -> kein Fehler anzeigen
        } catch {
            print("Fehler beim Laden der Kategorien:", error)
            errorMessage = "Kategorien konnten nicht geladen werden."
        }
    }

    private func loadRecommendations(userId: Int) async {
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
        } catch is CancellationError {
            // Ladevorgang wurde bewusst abgebrochen (z.B. neuer Refresh) -> kein Fehler anzeigen
        } catch {
            // Den echten Fehler mit ausgeben, damit man in der App sieht,
            // woran es liegt (Decoding, Netzwerk, RLS-Policy, ...).
            print("Fehler beim Laden der Empfehlungen:", error)
            errorMessage = "Empfehlungen konnten nicht geladen werden: \(error.localizedDescription)"
        }
    }

    private func loadSellerNames() async {
        let userIds = Set(recommendations.map { $0.userId })
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
            } catch is CancellationError {
                // Ladevorgang wurde bewusst abgebrochen -> kein Fehler anzeigen
            } catch {
                print("Fehler beim Laden des Verkäufernamens für \(id):", error)
                sellerNames[id] = "Unbekannt"
            }
        }
    }

    private func loadSellerRatings() async {
        let userIds = Set(recommendations.map { $0.userId })
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
            } catch is CancellationError {
                // Ladevorgang wurde bewusst abgebrochen -> kein Fehler anzeigen
            } catch {
                print("Fehler beim Laden der Bewertungen für \(id):", error)
            }
        }
    }

    private struct AvatarResult: Decodable {
        let Avatar: String?
    }

    private func loadCurrentUserAvatar() async {
        do {
            let session = try await supabase.auth.session
            guard let email = session.user.email else { return }

            let result: AvatarResult = try await supabase
                .from("User")
                .select("Avatar")
                .eq("email", value: email)
                .single()
                .execute()
                .value

            userAvatarPath = result.Avatar
            UserDefaults.standard.set(result.Avatar, forKey: "userAvatar")
        } catch is CancellationError {
            // Ladevorgang wurde bewusst abgebrochen -> kein Fehler anzeigen
        } catch {
            print("Fehler beim Laden des Avatars:", error)
        }
    }

    // Eigene User-ID laden, damit eigene Aufträge nicht empfohlen werden
    private func currentAppUserId() async -> Int? {
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
