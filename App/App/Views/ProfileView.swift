//
//  ProfileView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var body: some View {

        NavigationView {

            VStack {
                
                Text("Profile View")
                    .font(.largeTitle)
                Button(action : {
                    isLoggedIn = false
                },
                       label: {
                    Text("Ausloggen")
                })
            }
            .navigationTitle("Profil")
            
        }
    }
}

#Preview {
    ProfileView()
}
