//
//  ErstellenViewModel.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import Foundation
import SwiftUI
import Combine
import Supabase
import Combine

@MainActor
class ErstellenViewModel: ObservableObject {

    // Formular-Felder
    @Published var title = ""
    @Published var description = ""
    @Published var price = ""
    @Published var categoryId: Int?
    @Published var location = ""
    @Published var date = Date()
    @Published var flexibleTime = true
    @Published var notes = ""

    // Kategorien
    @Published var categories: [Category] = []
    @Published var categoriesError: String? = nil

    // UI-State
    @Published var isLoading = false

    // Kategorien laden
    func loadCategories() async {
        do {
            let response = try await supabase
                .from("Category")
                .select("id, title")
                .order("title")
                .execute()

            categories = try JSONDecoder().decode([Category].self, from: response.data)

            if categoryId == nil {
                categoryId = categories.first?.id
            }

        } catch {
            categoriesError = "Kategorien konnten nicht geladen werden."
            print("Fehler:", error)
        }
    }

    // Auftrag erstellen
    func createJob() async {

        guard !title.isEmpty else { return }

        isLoading = true

        let request = CreateJobRequest(
            title: title,
            description: description,
            price: Double(price),
            categoryId: categoryId,
            location: location,
            date: date,
            isFlexibleTime: flexibleTime,
            notes: notes
        )

        do {
            try await supabase
                .from("Order")
                .insert(request)
                .execute()

            // Erfolg – Formular zurücksetzen
            title = ""
            description = ""
            price = ""
            categoryId = categories.first?.id
            location = ""
            date = Date()
            flexibleTime = true
            notes = ""

        } catch {
            print("Fehler beim Erstellen:", error)
        }

        isLoading = false
    }
}
