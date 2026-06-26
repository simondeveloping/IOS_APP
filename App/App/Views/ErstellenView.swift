//
//  ErstellenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct ErstellenView: View {
    @State private var selectedTab = 0
    @StateObject private var ordersViewModel = MyOrdersViewModel() 
    @StateObject private var createViewModel = ErstellenViewModel() // ViewModel zum Erstellen eines neuen Auftrages

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Meine Aufträge").tag(0)
                Text("Neuer Auftrag").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                MyOrdersView(viewModel: ordersViewModel) // View der eigenen Aufträge
            } else {
                CreateJobFormView(viewModel: createViewModel) // Erstellen eines Auftrages View
            }
        }
        .onChange(of: selectedTab) { newTab in
            if newTab == 0 {
                Task {
                    await ordersViewModel.fetchMyOrders()
                }
            }
        }
    }
}
