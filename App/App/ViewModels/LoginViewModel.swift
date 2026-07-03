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
            print("Login erfolgreich für User ID: \(session.user.id)")
            
           
            let profile: UserProfile = try await supabase.database
                .from("User")
                .select()
                .eq("email", value: email.lowercased())
                .single()
                .execute()
                .value
            
            if let userId = profile.id {
                UserDefaults.standard.set(userId, forKey: "userId")
            }
            UserDefaults.standard.set(profile.Vorname, forKey: "userVorname")
            UserDefaults.standard.set(profile.Nachname, forKey: "userNachname")
            UserDefaults.standard.set(profile.avatar, forKey: "userAvatar")
            
            self.isLoading = false
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
        } catch {
            self.isLoading = false
            self.errorMessage = "E-Mail oder Passwort nicht korrekt."
            print("Fehler beim Login: \(error)")
        }
    }
}
