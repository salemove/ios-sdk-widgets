import Foundation

// MARK: Older history
extension SecureConversations.TranscriptModel {
    /// Moves the older-page key along with the history items copied from the other model, and
    /// clears it there so a load still in flight in that model is dropped.
    func takeOverOlderHistory(from source: OlderChatHistoryLoader) {
        olderHistoryLoader.replaceOlderPage(source.olderPage)
        source.replaceOlderPage(nil)
        action?(.olderHistoryStateUpdated(canLoad: olderHistoryLoader.canLoad, isLoading: false))
    }

    func loadOlderHistory() {
        olderHistoryLoader.loadOlderItems(
            into: historySection,
            knownMessageIds: { [weak self] in
                guard let self else { return [] }
                return Set(historySection.items.compactMap { $0.chatMessage?.id.uppercased() })
            },
            makeItem: { [weak self] message in
                guard let self else { return nil }
                return ChatItem(
                    with: message,
                    isCustomCardSupported: isCustomCardSupported,
                    fromHistory: environment.loadChatMessagesFromHistory()
                )
            },
            action: { [weak self] in self?.action?($0) }
        )
    }
}
