//
//  RegisterViewModel.swift
//  App
//
//  Created by Boromir on 05.06.26.
//



import SwiftUI
import Foundation
import Combine
import Supabase



@MainActor
class RegisterViewModel: ObservableObject {
    @Published var Vorname = ""
    @Published var Nachname = ""
    @Published var Email = ""
    @Published var Passwort = ""
    
    @Published var isRegistrationSuccessful = false
    @Published var errorMessage: String? = nil
    
    func register() async {
        do {
            let authResponse = try await supabase.auth.signUp(
                email: Email,
                password: Passwort
            )
            
            let neuesProfil = UserProfile(
                id: nil,
                email: Email,
                Vorname: Vorname,
                Nachname: Nachname
            )
            
            try await supabase
                .from("User")
                .insert(neuesProfil)
                .execute()
            
            self.isRegistrationSuccessful = true
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("Fehler bei der Registrierung: \(error)")
        }
    }
}
