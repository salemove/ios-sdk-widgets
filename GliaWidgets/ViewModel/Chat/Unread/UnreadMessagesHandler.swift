class UnreadMessagesHandler {
    private let unreadMessages: ObservableValue<Int>
    private let isWindowVisible: ObservableValue<Bool>
    private let isViewVisible: ObservableValue<Bool>

    init(unreadMessages: ObservableValue<Int>,
         isWindowVisible: ObservableValue<Bool>,
         isViewVisible: ObservableValue<Bool>) {
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
