//
//  MeineAuftraegeView.swift
//  App
//
//  Created by Boromir on 26.06.26.
//

import SwiftUI

struct MeineAuftraegeView: View {
    @StateObject private var viewModel = MeineAuftraegeViewModel()
    @AppStorage("userId") var userId: Int = 0
    @State private var selectedTab: AuftragTab = .alle

    enum AuftragTab: String, CaseIterable {
        case alle = "Alle"
        case erstellt = "Erstellt"
        case angenommen = "Angenommen"
    }

    var filteredOrders: [CombinedOrder] {
        switch selectedTab {
        case .alle:
            return viewModel.orders
        case .erstellt:
            return viewModel.orders.filter { $0.createrId == userId }
        case .angenommen:
            return viewModel.orders.filter { $0.accepterId == userId }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Lade Aufträge...")
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                Picker("Filter", selection: $selectedTab) {
                    ForEach(AuftragTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if filteredOrders.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Keine Aufträge gefunden")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(filteredOrders) { order in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(order.title)
                                    .font(.headline)
                                Spacer()
                                if let price = order.price {
                                    Text(String(format: "%.2f €", price))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                            }

                            Text(order.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)

                            Label(order.location, systemImage: "mappin")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack {
                                if order.createrId == userId {
                                    Label("Erstellt", systemImage: "person.badge.plus")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                if order.accepterId == userId {
                                    Label("Angenommen", systemImage: "hand.thumbsup")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle("Meine Aufträge")
        .task {
            guard userId > 0 else { return }
            await viewModel.loadOrders(for: userId)
        }
    }

}

#Preview {
    NavigationView {
        MeineAuftraegeView()
    }
}
