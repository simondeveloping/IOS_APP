//
//  OrderScannerShietView.swift
//  App
//
//  Created by Merry on 03.07.26.
//
import SwiftUI

struct OrderScannerSheetView: View {
    @StateObject private var viewModel = QRScannerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var scannedToken: String?
    @State private var showConfirmation = false
    @State private var showRatingForm = false
    @State private var ratingStars = 5
    @State private var ratingTitle = ""
    @State private var ratingDescription = ""

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.didRate {
                    ratingSubmittedView
                } else if showRatingForm {
                    ratingFormView
                } else if viewModel.didComplete {
                    successView
                } else if viewModel.isLoading {
                    loadingView
                } else {
                    scannerView
                }

                if let error = viewModel.errorMessage {
                    errorOverlay
                }
            }
            .navigationTitle(viewModel.didComplete || showRatingForm || viewModel.didRate ? "" : "Auftrag abschließen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !viewModel.didRate {
                        Button("Abbrechen") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Auftrag abschließen?", isPresented: $showConfirmation) {
                Button("Abbrechen", role: .cancel) {
                    scannedToken = nil
                }
                Button("Abschließen") {
                    guard let token = scannedToken else { return }
                    Task {
                        await viewModel.completeOrder(token: token)
                    }
                }
            } message: {
                Text("Bist du sicher, dass der Auftrag erfolgreich erledigt wurde?")
            }
        }
    }

    // MARK: - Scanner View

    private var scannerView: some View {
        ZStack {
            QRScannerView { token in
                scannedToken = token
                showConfirmation = true
            }
            .ignoresSafeArea()

            VStack {
                Text("QR Code des Annehmers scannen")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
                Spacer()
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Auftrag wird abgeschlossen...")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Auftrag abgeschlossen!")
                .font(.title2)
                .fontWeight(.bold)

            if let title = viewModel.completedOrderTitle {
                Text("\(title) wurde erfolgreich abgeschlossen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Jetzt bewerten") {
                withAnimation {
                    showRatingForm = true
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Fertig") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Rating Form View

    private var ratingFormView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Auftrag bewerten")
                    .font(.title2)
                    .fontWeight(.bold)

                if let title = viewModel.completedOrderTitle {
                    Text("\(title)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    Text("Bewertung")
                        .font(.headline)

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= ratingStars ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundColor(star <= ratingStars ? .yellow : .gray)
                                .onTapGesture {
                                    ratingStars = star
                                }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Titel (optional)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("z.B. Sehr zuverlässig", text: $ratingTitle)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Kommentar (optional)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $ratingDescription)
                        .frame(minHeight: 100)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }

                Button("Bewertung abschicken") {
                    Task {
                        let userId = UserDefaults.standard.integer(forKey: "userId")
                        await viewModel.submitRating(
                            stars: ratingStars,
                            title: ratingTitle.isEmpty ? "Bewertung" : ratingTitle,
                            description: ratingDescription,
                            fromUserId: userId
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
            .padding(24)
        }
    }

    // MARK: - Rating Submitted View

    private var ratingSubmittedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)

            Text("Bewertung abgegeben!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Vielen Dank für deine Bewertung.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Fertig") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Error Overlay

    private var errorOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            Text(viewModel.errorMessage ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Nochmal versuchen") {
                viewModel.errorMessage = nil
                scannedToken = nil
                showRatingForm = false
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
