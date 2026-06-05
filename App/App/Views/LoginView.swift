//
//  LoginView.swift
//  App
//
//  Created by Boromir on 05.06.26.
//

import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()
    var body: some View {
        VStack(){
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
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
