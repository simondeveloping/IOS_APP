//
//  EntdeckenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct EntdeckenView: View {

    var body: some View {

        NavigationView {

            VStack {

                Text("Entdecken View")
                    .font(.largeTitle)
            }
            .navigationTitle("Entdecken")
        }
    }
}

#Preview {
    EntdeckenView()
}
