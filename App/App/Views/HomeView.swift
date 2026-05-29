//
//  HomeView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct HomeView: View {

    var body: some View {

        NavigationView {

            VStack {

                Text("Home View")
                    .font(.largeTitle)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
