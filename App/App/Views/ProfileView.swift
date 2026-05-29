//
//  ProfileView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct ProfileView: View {

    var body: some View {

        NavigationView {

            VStack {

                Text("Profile View")
                    .font(.largeTitle)
            }
            .navigationTitle("Profil")
        }
    }
}

#Preview {
    ProfileView()
}
