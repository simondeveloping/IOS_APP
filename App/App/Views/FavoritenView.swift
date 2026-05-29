//
//  FavoritenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct FavoritenView: View {

    var body: some View {

        NavigationView {

            VStack {

                Text("Favoriten View")
                    .font(.largeTitle)
            }
            .navigationTitle("Favoriten")
        }
    }
}

#Preview {
    FavoritenView()
}
