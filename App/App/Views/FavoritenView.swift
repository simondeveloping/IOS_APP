//
//  FavoritenView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct FavoritenView: View {
    @StateObject private var viewModel = FavoritenViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    content
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.loadFavorites()
            }
            .task {
                await viewModel.loadFavorites()
            }
        }
    }

    // Header – gleicher Stil wie HomeView
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Favoriten")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Deine gespeicherten Aufträge.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // Inhalt
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

        } else if let errorMessage = viewModel.errorMessage {
            errorBanner(errorMessage)

        } else if viewModel.favoriteOrders.isEmpty {
            emptyState

        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(viewModel.favoriteOrders.count) gespeicherte Aufträge")
                    .font(.headline)
                    .fontWeight(.bold)

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.favoriteOrders) { order in
                        NavigationLink {
                            OrderDetailView(order: order, categoryName: "")
                        } label: {
                            favoriteCard(order)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // Leerer Zustand
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundStyle(Color(.systemGray3))

            Text("Noch keine Favoriten")
                .font(.headline)

            Text("Tippe in einem Auftrag auf das Herz-Icon, um ihn hier zu speichern.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // Fehlermeldung
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // Karte – gleicher Stil wie recommendationCard in HomeView
    private func favoriteCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(order.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                // Herz-Icon als visueller Hinweis, dass es ein Favorit ist
                Image(systemName: "heart.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
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
                Text(
                    price,
                    format: .currency(
                        code: Locale.current.currency?.identifier ?? "EUR"
                    )
                )
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
    FavoritenView()
}
