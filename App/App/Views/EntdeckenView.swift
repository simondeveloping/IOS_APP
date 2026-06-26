//
//  EntdeckenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct EntdeckenView: View {
    @StateObject private var viewModel = EntdeckenViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.body)
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                    }

                    if viewModel.isLoading && viewModel.allOrders.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else if viewModel.filteredOrders.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredOrders) { order in
                                NavigationLink {
                                    OrderDetailView(order: order, categoryName: viewModel.categoryName(for: order))
                                } label: {
                                    orderCard(order)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Entdecken")
            .searchable(text: $viewModel.searchText, prompt: "Suche nach Aufträgen...")
            .refreshable {
                await viewModel.loadOrders()
            }
            .task {
                await viewModel.loadOrders()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(viewModel.searchText.isEmpty ? "Aktuell gibt es keine Aufträge." : "Keine Ergebnisse für „\(viewModel.searchText)“")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 60)
    }

    private func orderCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(order.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text(order.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Label(order.location, systemImage: "mappin.and.ellipse")
                Spacer()
                Text(order.date.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let price = order.price {
                Text(price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    EntdeckenView()
}
