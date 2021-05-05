class UnreadMessagesHandler {
    private let unreadMessages: ObservableValue<Int>
    private let isWindowVisible: ObservableValue<Bool>
    private let isViewVisible: ObservableValue<Bool>
    private let isChatScrolledDown: ObservableValue<Bool>

    init(
        unreadMessages: ObservableValue<Int>,
        isWindowVisible: ObservableValue<Bool>,
        isViewVisible: ObservableValue<Bool>,
        isChatScrolledToBottom: ObservableValue<Bool>
    ) {
        self.unreadMessages = unreadMessages
        self.isWindowVisible = isWindowVisible
        self.isViewVisible = isViewVisible
        self.isChatScrolledDown = isChatScrolledToBottom
        isWindowVisible.addObserver(self) { _, _ in
            self.checkVisible()
        }
        isViewVisible.addObserver(self) { _, _ in
            self.checkVisible()
        }
        isChatScrolledDown.addObserver(self) { _, _ in
            self.checkVisible()
        }
    }

    deinit {
        isWindowVisible.removeObserver(self)
        isViewVisible.removeObserver(self)
        isChatScrolledDown.removeObserver(self)
    }

    func received(_ count: Int) {
        if !(isWindowVisible.value && isViewVisible.value) {
            unreadMessages.value += count
        } else if !isChatScrolledDown.value {
            unreadMessages.value += count
        }
    }

    private func checkVisible() {
        if isWindowVisible.value,
           isViewVisible.value,
           isChatScrolledDown.value {
            unreadMessages.value = 0
        }
    }
}
