//
//  HomeView.swift
//  App
//
//  Created by Merry on 29.05.26.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("userVorname") private var userVorname: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    banner
                    categories
                    recommendations
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.loadHomeData()
            }
            .task {
                await viewModel.loadHomeData()
            }
        }
    }

    // Begrüßung oben
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Hallo \(userVorname.isEmpty ? "" : userVorname)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Schön, dass du da bist.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 58))
                .foregroundStyle(Color(.systemGray3))
        }
    }

    // Einleitungsbereich
    private var banner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(height: 160)

            VStack(spacing: 10) {
                Image(systemName: "hand.raised.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)

                Text("Finde passende Hilfe")
                    .font(.headline)

                Text("Entdecke Aufträge in deiner Nähe.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // Kategorien aus der Datenbank
    private var categories: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Kategorien") {
                viewModel.selectedCategoryId = nil
            }

            if viewModel.categories.isEmpty && viewModel.isLoading {
                ProgressView()
            } else if viewModel.categories.isEmpty {
                emptyText("Keine Kategorien gefunden.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.categories) { category in
                            categoryButton(category)
                        }
                    }
                }
            }
        }
    }

    // Aufträge die man annehmen kann
    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Empfehlungen für dich") {
                viewModel.selectedCategoryId = nil
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if viewModel.recommendations.isEmpty && viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredRecommendations.isEmpty {
                emptyText(emptyRecommendationsText)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredRecommendations) { order in
                        NavigationLink {
                            OrderDetailView(order: order, categoryName: categoryName(for: order))
                        } label: {
                            recommendationCard(order)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func sectionTitle(_ title: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            Button("Alle anzeigen", action: action)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func categoryButton(_ category: Category) -> some View {
        let isSelected = viewModel.selectedCategoryId == category.id

        return Button {
            viewModel.toggleCategory(category)
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .blue)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.12))
                    .clipShape(Circle())

                Text(category.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            .frame(width: 105, height: 105)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func recommendationCard(_ order: Order) -> some View {
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

    private func categoryName(for order: Order) -> String {
        guard let categoryId = order.categoryId else { return "Keine Kategorie" }
        return viewModel.categories.first { $0.id == Int(categoryId) }?.title ?? "Keine Kategorie"
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var emptyRecommendationsText: String {
        if viewModel.selectedCategoryId != nil {
            return "Für diese Kategorie gibt es gerade keine Aufträge."
        }

        return "Aktuell gibt es keine passenden Aufträge."
    }
}

private struct OrderDetailView: View {
    let order: Order
    let categoryName: String

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
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Auftragsdetails")
        .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    HomeView()
}
