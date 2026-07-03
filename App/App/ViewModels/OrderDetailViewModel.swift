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

    func sendRequest(for order: Order) async {
        errorMessage = nil
        isLoading = true

        do {
            let session = try await supabase.auth.session
            let email = session.user.email ?? ""

            let payload = AcceptedOrderPayload(
                orderId: order.id,
                createrId: order.userId,
                accepterId: Int64(userId)
            )

            try await supabase
                .from("AcceptedOrder")
                .insert(payload)
                .execute()

            successMessage = "Anfrage erfolgreich gesendet!"

        } catch {
            print("Fehler beim Senden der Anfrage:", error)
            errorMessage = "Anfrage konnte nicht gesendet werden."
        }

        isLoading = false
    }
}
