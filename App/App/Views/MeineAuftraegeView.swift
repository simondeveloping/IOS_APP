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
            return viewModel.orders.filter { $0.createrId == userId && $0.accepterId == 0 }
        case .angenommen:
            return viewModel.orders.filter { $0.createrId == userId && $0.accepterId != 0 }
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
                        Group {
                            if order.accepterId != 0 {
                                NavigationLink(destination: ChatView(
                                    orderId: order.orderId,
                                    orderTitle: order.title,
                                    otherUserId: order.createrId == userId ? order.accepterId : order.createrId,
                                    otherUserName: viewModel.name(for: order.createrId == userId ? order.accepterId : order.createrId)
                                )) {
                                    orderRow(order: order)
                                }
                            } else {
                                orderRow(order: order)
                            }
                        }
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
        .refreshable {
            guard userId > 0 else { return }
            await viewModel.loadOrders(for: userId)
        }
    }

    @ViewBuilder
    private func orderRow(order: CombinedOrder) -> some View {
        HStack {
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
                    if order.createrId == userId, order.accepterId == 0 {
                        Label("Erstellt", systemImage: "person.badge.plus")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    if order.accepterId != 0 {
                        if order.createrId == userId {
                            Label("Angenommen von \(viewModel.name(for: order.accepterId))", systemImage: "hand.thumbsup")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Label("Erstellt von \(viewModel.name(for: order.createrId))", systemImage: "person")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }

            if order.unreadCount > 0 {
                Text("\(order.unreadCount)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }

}

#Preview {
    NavigationView {
        MeineAuftraegeView()
    }
}
