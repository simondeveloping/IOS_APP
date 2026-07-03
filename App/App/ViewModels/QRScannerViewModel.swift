//
//  QRScannerViewModel.swift
//  App
//
//  Created by Merry on 03.07.26.
//
import Foundation
import Supabase
import Combine

@MainActor
class QRScannerViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didComplete = false
    @Published var completedOrderTitle: String?

    func completeOrder(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // AcceptedOrder mit diesem Token suchen
            struct TokenResult: Decodable {
                let id: Int
                let order_id: Int
            }

            let results: [TokenResult] = try await supabase
                .from("AcceptedOrder")
                .select("id, order_id")
                .eq("completion_token", value: token)
                .eq("is_completed", value: false)
                .execute()
                .value

            guard let match = results.first else {
                errorMessage = "Ungültiger oder bereits verwendeter QR Code."
                isLoading = false
                return
            }

            // Als abgeschlossen markieren
            try await supabase
                .from("AcceptedOrder")
                .update(["is_completed": true])
                .eq("id", value: match.id)
                .execute()

            // Titel des Auftrags für Erfolgsmeldung holen
            struct OrderTitle: Decodable {
                let title: String
            }

            let order: OrderTitle = try await supabase
                .from("Order")
                .select("title")
                .eq("id", value: match.order_id)
                .single()
                .execute()
                .value

            completedOrderTitle = order.title
            didComplete = true

        } catch {
            print("Fehler beim Abschließen:", error)
            errorMessage = "Auftrag konnte nicht abgeschlossen werden."
        }

        isLoading = false
    }
}
