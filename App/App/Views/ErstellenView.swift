//
//  ErstellenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct ErstellenView: View {
    @State private var selectedTab = 0
    @State private var showScanner = false
    @StateObject private var ordersViewModel = MyOrdersViewModel()
    @StateObject private var createViewModel = ErstellenViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Meine Aufträge").tag(0)
                    Text("Neuer Auftrag").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    MyOrdersView(viewModel: ordersViewModel)
                } else {
                    CreateJobFormView(viewModel: createViewModel)
                }
            }
            .navigationTitle("Aufträge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Scanner-Button nur anzeigen wenn Tab "Meine Aufträge" aktiv
                if selectedTab == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                        }
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                OrderScannerSheetView()
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 0 {
                Task {
                    await ordersViewModel.fetchMyOrders()
                }
            }
        }
        .onChange(of: createViewModel.didCreateJob) { _, created in
            if created {
                withAnimation {
                    selectedTab = 0
                }
                ordersViewModel.showBannerAndHide()
                Task {
                    await ordersViewModel.fetchMyOrders()
                }
                createViewModel.didCreateJob = false
            }
        }
    }
}
