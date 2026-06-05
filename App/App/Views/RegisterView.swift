//
//  Register.swift
//  App
//
//  Created by Boromir on 05.06.26.
//
import SwiftUI
struct RegisterView : View{
    @State private var test = "hallo"
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    var body : some View{
        VStack(){
            Text("Registrieren")
            TextField("Email", text: $test).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $test).textFieldStyle(.roundedBorder)
            Button(action: {
                
            }, label:{
                Text("Weiter")
            })
            Button("Abbrechen"){
                dismiss()
            }
        }
        .padding()
        
    }
}
