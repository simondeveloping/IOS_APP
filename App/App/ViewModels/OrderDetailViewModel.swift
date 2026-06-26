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
    
    @AppStorage("userId") var userId: Int = 0

    func sendRequest(for order: Order) async {
        errorMessage = nil
        isLoading = true

        do {
            let session = try await supabase.auth.session
            let email = session.user.email ?? ""

            let payload = AcceptedOrderPayload(
                orderId: order.id,
                createrId: order.userId,     // Ersteller des Auftrags
                accepterId: Int64(userId)      // aktuell eingeloggter User
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
