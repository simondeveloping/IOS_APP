//
//  Register.swift
//  App
//
//  Created by Boromir on 05.06.26.
//
//  Register.swift
//  App

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Registrieren")
                .font(.largeTitle)
                .bold()
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 15) {
                TextField("Vorname", text: $viewModel.Vorname)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Nachname", text: $viewModel.Nachname)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email", text: $viewModel.Email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Passwort", text: $viewModel.Passwort)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: {
                Task {
                    await viewModel.register()
                }
            }, label: {
                Text("Registrieren & Weiter")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            
            Button("Abbrechen") {
                dismiss()
            }
            .foregroundColor(.red)
        }
        .padding()
        .onChange(of: viewModel.isRegistrationSuccessful) {
            if viewModel.isRegistrationSuccessful {
                dismiss()
            }
        }
    }
}
