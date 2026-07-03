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

    var body: some View {
        NavigationStack {
            ZStack {
                // Kamera
                if !viewModel.didComplete && !viewModel.isLoading {
                    QRScannerView { token in
                        scannedToken = token
                        showConfirmation = true
                    }
                    .ignoresSafeArea()

                    // Anleitung oben
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

                // Ladeindikator
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Auftrag wird abgeschlossen...")
                            .foregroundStyle(.secondary)
                    }
                }

                // Erfolgsmeldung
                if viewModel.didComplete {
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

                        Button("Fertig") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                // Fehlermeldung
                if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.red)

                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Nochmal versuchen") {
                            viewModel.errorMessage = nil
                            scannedToken = nil
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Auftrag abschließen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            // Bestätigung vor dem Abschließen
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
}
