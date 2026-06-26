import Foundation
import Supabase
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var channel: RealtimeChannelV2?
    private var streamTask: Task<Void, Never>?
    private var currentOrderId: Int = 0
    private var currentUserId: Int = 0

    func loadMessages(orderId: Int, userId: Int, otherUserId: Int) async {
        isLoading = true
        errorMessage = nil
        currentOrderId = orderId
        currentUserId = userId
        do {
            let response = try await supabase
                .from("Message")
                .select()
                .eq("order_id", value: orderId)
                .order("created_at", ascending: true)
                .execute()

            let allMessages: [Message] = try JSONDecoder().decode([Message].self, from: response.data)
            messages = allMessages.filter { $0.sender_id == userId || $0.receiver_id == userId }
        } catch {
            print("Fehler beim Laden der Nachrichten:", error)
            errorMessage = "Nachrichten konnten nicht geladen werden"
        }
        isLoading = false

        subscribeToNewMessages(orderId: orderId, userId: userId)
    }

    func sendMessage(orderId: Int, senderId: Int, receiverId: Int, text: String) async {
        let payload = SendMessagePayload(
            order_id: orderId,
            sender_id: senderId,
            receiver_id: receiverId,
            message: text
        )

        do {
            try await supabase
                .from("Message")
                .insert(payload)
                .execute()
        } catch {
            print("Fehler beim Senden der Nachricht:", error)
            errorMessage = "Nachricht konnte nicht gesendet werden"
        }
    }

    private func subscribeToNewMessages(orderId: Int, userId: Int) {
        unsubscribe()

        let newChannel = supabase.channel("messages-\(orderId)-\(userId)")
        channel = newChannel

        streamTask = Task { [weak self] in
            let changes = await newChannel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "Message",
                filter: "order_id=eq.\(orderId)"
            )

            await newChannel.subscribe()

            for await change in changes {
                guard let self else { break }
                let decoder = JSONDecoder()
                if let data = try? JSONEncoder().encode(change.record),
                   let newMessage = try? decoder.decode(Message.self, from: data) {
                    if !self.messages.contains(where: { $0.id == newMessage.id }) {
                        self.messages.append(newMessage)
                        self.messages.sort { ($0.created_at ?? "") < ($1.created_at ?? "") }
                    }
                }
            }
        }
    }

    func unsubscribe() {
        streamTask?.cancel()
        streamTask = nil
        if let channel = channel {
            Task { await supabase.removeChannel(channel) }
            self.channel = nil
        }
    }

    deinit {
        streamTask?.cancel()
    }
}
