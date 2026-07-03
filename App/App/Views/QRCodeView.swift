//
//  QRCodeView.swift
//  App
//
//  Created by Merry on 03.07.26.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let token: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("QR Code vorzeigen")
                .font(.title2)
                .fontWeight(.bold)

            Text("Lass den Auftraggeber diesen Code scannen, um den Auftrag abzuschließen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let image = generateQRCode(from: token) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }

            Text("Token: \(token)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Schließen") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}