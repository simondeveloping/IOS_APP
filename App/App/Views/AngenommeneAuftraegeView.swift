import SwiftUI

struct AngenommeneAuftraegeView: View {
    @StateObject private var viewModel = AngenommeneAuftraegeViewModel()
    @AppStorage("userId") var userId: Int = 0
    @State private var selectedTokenForQR: String?

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

            } else if viewModel.orders.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Keine angenommenen Aufträge")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()

            } else {
                List(viewModel.orders) { order in
                    orderRow(order)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Angenommene Aufträge")
        .task {
            guard userId > 0 else { return }
            await viewModel.loadOrders(for: userId)
        }
        .refreshable {
            guard userId > 0 else { return }
            await viewModel.loadOrders(for: userId)
        }
        .sheet(item: Binding(
            get: { selectedTokenForQR.map { IdentifiableToken(value: $0) } },
            set: { selectedTokenForQR = $0?.value }
        )) { identifiable in
            QRCodeView(token: identifiable.value)
                .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private func orderRow(_ order: AcceptedOrderItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.title)
                    .font(.headline)
                Spacer()
                if order.isCompleted {
                    Label("Abgeschlossen", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("Offen", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            if let price = order.price {
                Text(String(format: "%.2f €", price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Text(order.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Label(order.location, systemImage: "mappin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Label(order.createrName, systemImage: "person")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            chatButton(order)

            if !order.isCompleted, let token = order.completionToken {
                qrButton(token)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func chatButton(_ order: AcceptedOrderItem) -> some View {
        NavigationLink(destination: ChatView(
            orderId: order.orderId,
            orderTitle: order.title,
            otherUserId: order.createrId,
            otherUserName: order.createrName
        )) {
            Label("Chat", systemImage: "message")
                .font(.caption)
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    private func qrButton(_ token: String) -> some View {
        Button {
            selectedTokenForQR = token
        } label: {
            Label("QR Code anzeigen", systemImage: "qrcode")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
    }
}

private struct IdentifiableToken: Identifiable {
    let id = UUID()
    let value: String
}
