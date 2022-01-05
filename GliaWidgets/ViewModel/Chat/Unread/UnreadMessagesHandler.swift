import Foundation

class UnreadMessagesHandler {
    private let unreadMessages: ObservableValue<Int>
    private let isWindowVisible: ObservableValue<Bool>
    private let isViewVisible: ObservableValue<Bool>
    private let isChatScrolledToBottom: ObservableValue<Bool>

    init(
        unreadMessages: ObservableValue<Int>,
        isWindowVisible: ObservableValue<Bool>,
        isViewVisible: ObservableValue<Bool>,
        isChatScrolledToBottom: ObservableValue<Bool>
    ) {
        self.unreadMessages = unreadMessages
        self.isWindowVisible = isWindowVisible
        self.isViewVisible = isViewVisible
        self.isChatScrolledToBottom = isChatScrolledToBottom
        isWindowVisible.addObserver(self) { [weak self] _, _ in
            self?.checkVisible()
        }
        isViewVisible.addObserver(self) { [weak self] _, _ in
            self?.checkVisible()
        }
        isChatScrolledToBottom.addObserver(self) { [weak self] _, _ in
            self?.checkVisible()
        }
    }

    deinit {
        isWindowVisible.removeObserver(self)
        isViewVisible.removeObserver(self)
        isChatScrolledToBottom.removeObserver(self)
    }

    func received(_ count: Int) {
        if !(isWindowVisible.value && isViewVisible.value) {
            unreadMessages.value += count
        } else if !isChatScrolledToBottom.value {
            unreadMessages.value += count
        }
    }

    private func checkVisible() {
        if isWindowVisible.value,
           isViewVisible.value,
           isChatScrolledToBottom.value {
            unreadMessages.value = 0
        }
    }
}
