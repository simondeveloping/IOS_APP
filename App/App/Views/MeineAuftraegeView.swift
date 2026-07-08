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
                            if let (partnerId, partnerName) = chatPartner(for: order) {
                                NavigationLink(destination: ChatView(
                                    orderId: order.orderId,
                                    orderTitle: order.title,
                                    otherUserId: partnerId,
                                    otherUserName: partnerName
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

    /// Ermittelt, ob und mit wem für diesen Auftrag gerade gechattet werden kann.
    /// - Bereits angenommen: Chat mit der jeweils anderen Partei (Creator <-> Accepter).
    /// - Von mir erstellt, noch nicht angenommen: Chat mit dem (einen) Interessenten,
    ///   falls schon jemand geschrieben hat.
    /// - Sonst: kein Chat möglich.
    private func chatPartner(for order: CombinedOrder) -> (id: Int, name: String)? {
        if order.accepterId != 0 {
            let partnerId = order.createrId == userId ? order.accepterId : order.createrId
            return (partnerId, viewModel.name(for: partnerId))
        }

        if order.createrId == userId, order.chatPartnerId != 0 {
            return (order.chatPartnerId, order.chatPartnerName)
        }

        return nil
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
                        if order.chatPartnerId != 0 {
                            Label("Anfrage von \(order.chatPartnerName)", systemImage: "envelope")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else {
                            Label("Erstellt", systemImage: "person.badge.plus")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
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
