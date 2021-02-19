class UnreadMessagesHandler {
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
            self.checkVisible()
        }
        isViewVisible.addObserver(self) { _, _ in
            self.checkVisible()
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

    private func checkVisible() {
        if isWindowVisible.value && isViewVisible.value {
            unreadMessages.value = 0
        }
    }
}
