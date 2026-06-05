//
//  LoginViewModel.swift
//  App
//
//  Created by Boromir on 05.06.26.
//

import Foundation
import SwiftUI
internal import Combine

class LoginViewModel : ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login(){
        self.isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            if self.password == "password" {
                print("Login erfolgreich!")
                
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                
            } else {
                self.errorMessage = "Zugangsdaten nicht korrekt."
            }
        }
    }
}
