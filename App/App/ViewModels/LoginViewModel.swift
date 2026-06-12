//
//  LoginViewModel.swift
//  App
//
//  Created by Boromir on 05.06.26.
//


import Foundation
import SwiftUI
import Combine
import Supabase
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.isLoading = false
            print("Login erfolgreich für User ID: \(session.user.id)")
            
           
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
        } catch {
            self.isLoading = false
            self.errorMessage = "E-Mail oder Passwort nicht korrekt."
            print("Fehler beim Login: \(error)")
        }
    }
}
