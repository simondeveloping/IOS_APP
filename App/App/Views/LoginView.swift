//
//  LoginView.swift
//  App
//
//  Created by Boromir on 05.06.26.
//

import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegisterView = false
    var body: some View {
        VStack(spacing: 15){
            Text("Login")
                .font(.largeTitle)
                .bold()
            TextField("Email", text: $viewModel.email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $viewModel.password).textFieldStyle(.roundedBorder)
            
            //shadow Message :)
            if let errorMessage = viewModel.errorMessage{
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        
            if viewModel.isLoading{
                ProgressView()
            } else {
                Button("Einloggen"){
                    viewModel.login()
                }
            }
            Text("Noch kein Konto?").padding(.top, 40)
            Button("Jetzt Registrieren"){
                    showRegisterView = true
            }
        }
        .padding()
        .sheet(isPresented: $showRegisterView){
            RegisterView()
        }
    }
}

#Preview {
    LoginView()
}
