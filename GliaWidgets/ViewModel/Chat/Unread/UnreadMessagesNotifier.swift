class UnreadMessagesNotifier {
    private let unreadMessages: ValueProvider<Int>
    private let isWindowVisible: ValueProvider<Bool>
    private let isViewVisible: ValueProvider<Bool>

    init(unreadMessages: ValueProvider<Int>,
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

    func received(_ count: Int) {
        if !(isWindowVisible.value && isViewVisible.value) {
            unreadMessages.value += count
        }
    }

    private func updateUnreadMessageCount() {
        if isWindowVisible.value && isViewVisible.value {
            unreadMessages.value = 0
        }
    }
}
