import SwiftUI

struct ChatView: View {
    let orderId: Int
    let orderTitle: String
    let otherUserId: Int
    let otherUserName: String
    @StateObject private var viewModel = ChatViewModel()
    @AppStorage("userId") var userId: Int = 0
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Lade Nachrichten...")
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(
                                    message: message.message,
                                    isFromMe: message.sender_id == userId,
                                    time: formatTime(message.created_at)
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Nachricht schreiben...", text: $messageText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    messageText = ""
                    Task {
                        await viewModel.sendMessage(
                            orderId: orderId,
                            senderId: userId,
                            receiverId: otherUserId,
                            text: text
                        )
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat mit \(otherUserName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadMessages(orderId: orderId, userId: userId, otherUserId: otherUserId)
            }
        }
        .onDisappear {
            viewModel.unsubscribe()
        }
    }

    private func formatTime(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return timeFormatter.string(from: date)
        }
        return ""
    }
}

struct ChatBubble: View {
    let message: String
    let isFromMe: Bool
    let time: String

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isFromMe ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isFromMe ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !isFromMe { Spacer(minLength: 60) }
        }
    }
}
