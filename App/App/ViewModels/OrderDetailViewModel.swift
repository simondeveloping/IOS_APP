//
//  OrderDetailViewModel.swift
//  App
//
//  Created by Merry on 26.06.26.
//
import SwiftUI
import Combine
import Supabase

@MainActor
class OrderDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var sellerName: String = ""
    
    
    @Published var didAcceptOrder = false
   
    @Published var isFavorite = false
    
    private var currentFavoriteId: Int?
    
    @AppStorage("userId") var userId: Int = 0

    func loadSellerName(for userId: Int) async {
        do {
            let response = try await supabase
                .from("User")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            let user: UserProfile = try JSONDecoder().decode(UserProfile.self, from: response.data)
            sellerName = "\(user.Vorname) \(user.Nachname)"
        } catch {
            print("Fehler beim Laden des Verkäufernamens:", error)
            sellerName = "Verkäufer"
        }
    }

    // beim Öffnen der View aufrufen
    
    func sendRequest(for order: Order) async {
            isLoading = true
            errorMessage = nil

            do {
                let token = UUID().uuidString
                
                let payload = AcceptedOrderPayload(
                    orderId: order.id,
                    createrId: order.userId,
                    accepterId: userId,
                    completionToken: token
                )

                try await supabase
                    .from("AcceptedOrder")
                    .insert(payload)
                    .execute()

                didAcceptOrder = true  // löst dismiss in der View aus

            } catch {
                print("Fehler beim Annehmen:", error)
                errorMessage = "Auftrag konnte nicht angenommen werden."
            }

            isLoading = false
        }

    
        func loadCurrentUserAndFavoriteStatus(for order: Order) async {
            do {
                // prüfen, ob bereits favorisiert
                let existing: [Favorite] = try await supabase
                    .from("Favorites")
                    .select()
                    .eq("user_id", value: userId)
                    .eq("order_id", value: order.id)
                    .execute()
                    .value

                if let existingFavorite = existing.first {
                    isFavorite = true
                    currentFavoriteId = existingFavorite.id
                } else {
                    isFavorite = false
                    currentFavoriteId = nil
                }

            }catch {
                print("Fehler beim Senden der Anfrage:", error)
                errorMessage = "Anfrage konnte nicht gesendet werden."
            }
        }

        func toggleFavorite(for order: Order) async {

            do {
                if isFavorite, let favoriteId = currentFavoriteId {
                    // Favorit entfernen
                    try await supabase
                        .from("Favorites")
                        .delete()
                        .eq("id", value: favoriteId)
                        .execute()

                    isFavorite = false
                    currentFavoriteId = nil
                } else {
                    // Favorit hinzufügen
                    let payload = FavoritePayload(userId: userId, orderId: order.id)

                    let inserted: Favorite = try await supabase
                        .from("Favorites")
                        .insert(payload)
                        .select()
                        .single()
                        .execute()
                        .value

                    isFavorite = true
                    currentFavoriteId = inserted.id
                }
            } catch {
                print("Fehler beim Favorisieren:", error)
                errorMessage = "Aktion konnte nicht ausgeführt werden."
            }
        }

    
}
