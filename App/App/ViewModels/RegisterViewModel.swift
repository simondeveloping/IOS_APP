//
//  RegisterViewModel.swift
//  App
//
//  Created by Boromir on 05.06.26.
//
import SwiftUI
import Foundation
internal import Combine

class RegisterViewModel: ObservableObject{
    @Published var Vorname = ""
    @Published var Nachname = ""
    @Published var Email = ""
    @Published var Passwort = ""
    
    func register(){
        
    }
}
