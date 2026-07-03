//
//  OrderDetailView.swift
//  App
//
//  Created by Merry on 26.06.26.
//
import SwiftUI

struct OrderDetailView: View {
    let order: Order
    let categoryName: String
    @StateObject private var viewModel = OrderDetailViewModel()
    @State private var showChat = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(order.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                detailRow("Kategorie", categoryName, icon: "square.grid.2x2")
                detailRow("Ort", order.location, icon: "mappin.and.ellipse")
                detailRow("Datum", order.date.formatted(date: .long, time: .omitted), icon: "calendar")
                detailRow("Flexible Uhrzeit", order.isFlexibleTime ? "Ja" : "Nein", icon: "clock")

                if let price = order.price {
                    detailRow("Preisvorstellung", price.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR")), icon: "eurosign.circle")
                }

                detailText("Beschreibung", order.description)
                detailText("Zusätzliche Hinweise", order.notes.isEmpty ? "Keine Hinweise" : order.notes)

                NavigationLink(
                    destination: ChatView(
                        orderId: Int(order.id),
                        orderTitle: order.title,
                        otherUserId: Int(order.userId),
                        otherUserName: viewModel.sellerName
                    ),
                    isActive: $showChat
                ) { EmptyView() }

                HStack {
                    Button {
                        showChat = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Anfrage stellen")
                                .font(.headline)
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    Button {
                        Task {
                            await viewModel.sendRequest(for: order)
                        }
                    } label: {
                        Text("Auftrag annehmen")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                        Button("OK") { viewModel.errorMessage = nil }
                    } message: {
                        Text(viewModel.errorMessage ?? "")
                    }
                    .alert("Erfolg", isPresented: .constant(viewModel.successMessage != nil)) {
                        Button("OK") { viewModel.successMessage = nil }
                    } message: {
                        Text(viewModel.successMessage ?? "")
                    }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Auftragsdetails")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSellerName(for: Int(order.userId))
        }
    }

    private func detailRow(_ title: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func detailText(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
