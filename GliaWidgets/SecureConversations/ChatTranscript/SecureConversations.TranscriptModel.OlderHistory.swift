import Foundation

// MARK: Older history
extension SecureConversations.TranscriptModel {
    func loadOlderHistory() {
        guard olderHistoryLoader.canStartLoading else { return }
        environment.openTelemetry.logger.i(.chatScreenHistoryLoading)
        action?(.olderHistoryStateUpdated(canLoad: true, isLoading: true))
        olderHistoryLoader.load { [weak self] messages in
            self?.olderHistoryLoaded(messages)
        }
    }

    private func olderHistoryLoaded(_ messages: [ChatMessage]?) {
        if let messages {
            environment.openTelemetry.logger.i(.chatScreenHistoryLoaded) {
                $0[.messageCount] = .string("\(messages.count)")
            }
            let knownMessageIds = Set(historySection.items.compactMap { $0.chatMessage?.id.uppercased() })
            let items = messages
                .filter { !knownMessageIds.contains($0.id.uppercased()) }
                .compactMap {
                    ChatItem(
                        with: $0,
                        isCustomCardSupported: isCustomCardSupported,
                        fromHistory: environment.loadChatMessagesFromHistory()
                    )
                }
            if !items.isEmpty {
                historySection.prepend(items)
                action?(.prependRows(items.count, to: historySection.index))
            }
        }
        action?(.olderHistoryStateUpdated(canLoad: olderHistoryLoader.canLoad, isLoading: false))
    }
}
