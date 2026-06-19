//
//  BewertungenView.swift
//  App
//

import SwiftUI

struct BewertungenView: View {
    let userId: Int

    @StateObject private var vm = BewertungenViewModel()

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
            } else if vm.ratings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Noch keine Bewertungen")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.ratings) { rating in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= rating.stars ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundColor(index <= rating.stars ? .yellow : .gray)
                                }
                            }
                            Spacer()
                            Text("von \(vm.name(for: rating.fromUser_id))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(rating.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        if !rating.description.isEmpty {
                            Text(rating.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Bewertungen")
        .task {
            await vm.loadRatings(for: userId)
        }
    }
}
