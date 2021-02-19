class UnreadMessagesNotifier {
    private let unreadMessages: ValueProvider<UInt>
    private let isWindowVisible: ValueProvider<Bool>
    private let isViewVisible: ValueProvider<Bool>

    init(unreadMessages: ValueProvider<UInt>,
         isWindowVisible: ValueProvider<Bool>,
         isViewVisible: ValueProvider<Bool>) {
        self.unreadMessages = unreadMessages
        self.isWindowVisible = isWindowVisible
        self.isViewVisible = isViewVisible
        isWindowVisible.addObserver(self) { _, _ in
            self.updateUnreadMessageCount()
        }
        isViewVisible.addObserver(self) { _, _ in
            self.updateUnreadMessageCount()
        }
    }

    deinit {
        isWindowVisible.removeObserver(self)
        isViewVisible.removeObserver(self)
    }

    func messageReceived() {
        if !(isWindowVisible.value && isViewVisible.value) {
            unreadMessages.value += 1
        }
    }

    private func updateUnreadMessageCount() {
        if isWindowVisible.value && isViewVisible.value {
            unreadMessages.value = 0
        }
    }
}
