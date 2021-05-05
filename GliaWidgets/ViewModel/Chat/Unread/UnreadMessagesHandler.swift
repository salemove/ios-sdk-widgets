class UnreadMessagesHandler {
    private let unreadMessages: ObservableValue<Int>
    private let isWindowVisible: ObservableValue<Bool>
    private let isViewVisible: ObservableValue<Bool>
    let isChatScrolledDown: ObservableValue<Bool>

    init(
        unreadMessages: ObservableValue<Int>,
        isWindowVisible: ObservableValue<Bool>,
        isViewVisible: ObservableValue<Bool>,
        isChatScrolledDown: ObservableValue<Bool>
    ) {
        self.unreadMessages = unreadMessages
        self.isWindowVisible = isWindowVisible
        self.isViewVisible = isViewVisible
        self.isChatScrolledDown = isChatScrolledDown
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
        print("Checking for visibility:")
        print("windowVisible = \(isWindowVisible.value)")
        print("viewVisible = \(isViewVisible.value)")
        print("chatScrolledDown = \(isChatScrolledDown.value)")
        if isWindowVisible.value, isViewVisible.value, isChatScrolledDown.value {
            unreadMessages.value = 0
        }
        print("Current unread messages: \(unreadMessages.value)")
    }
}
