import Foundation
// MARK: Custom cards

extension ChatViewModel {
    @MainActor
    func sendSelectedCustomCardOption(
        _ option: HtmlMetadata.Option,
        for messageId: MessageRenderer.Message.Identifier
    ) async {
        guard case .engaged = interactor.state else { return }
        let attachment = CoreSdkClient.Attachment(
            type: .singleChoiceResponse,
            selectedOption: option.value,
            options: nil,
            files: nil,
            imageUrl: nil
        )

        let payload = environment.createSendMessagePayload(option.text, attachment)
        let outgoingMessage = OutgoingMessage(
            payload: payload,
            relation: .customCard(messageId: messageId)
        )

        registerReceivedMessage(messageId: payload.messageId.rawValue)

        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        do {
            let message = try await interactor.send(messagePayload: payload)
            onSuccessSendSelectedCustomCardOption(
                message: message,
                messageId: messageId,
                outgoingMessage: outgoingMessage,
                option: option
            )
        } catch {
            onFailureSendSelectedCustomCardOption(
                messageId: messageId,
                outgoingMessage: outgoingMessage
            )
        }
    }

    @MainActor
    func onSuccessSendSelectedCustomCardOption(
        message: CoreSdkClient.Message,
        messageId: MessageRenderer.Message.Identifier,
        outgoingMessage: OutgoingMessage,
        option: HtmlMetadata.Option
    ) {
        self.updateCustomCard(
            messageId: messageId,
            selectedOptionValue: option.value,
            isActive: false
        )
        self.replace(
            outgoingMessage,
            uploads: [],
            with: message,
            in: self.messagesSection
        )
        self.action?(.scrollToBottom(animated: true))
    }

    @MainActor
    func onFailureSendSelectedCustomCardOption(
        messageId: MessageRenderer.Message.Identifier,
        outgoingMessage: OutgoingMessage
    ) {
        updateCustomCard(
            messageId: messageId,
            selectedOptionValue: nil,
            isActive: true
        )
        markMessageAsFailed(
            outgoingMessage,
            in: messagesSection
        )
    }

    func updateCustomCard(
        messageId: MessageRenderer.Message.Identifier,
        selectedOptionValue: String?,
        isActive: Bool
    ) {
        guard let index = messagesSection.items
            .enumerated()
            .first(where: {
                guard case .customCard(let msg, _, _, _) = $0.element.kind else { return false }
                return msg.id == messageId.rawValue
            })?.offset
        else { return }

        let customCardItem = messagesSection[index]

        guard case .customCard(
            let message,
            let showsImage,
            let imageUrl,
            _
        ) = customCardItem.kind else { return }

        message.attachment?.selectedOption = selectedOptionValue
        let item = ChatItem(kind: .customCard(
            message,
            showsImage: showsImage,
            imageUrl: imageUrl,
            isActive: isActive
        ))
        messagesSection.replaceItem(at: index, with: item)

        // Reload card to hide it if `shouldShowCard` returns `false` or
        // `isActive` is `true in case when sending request with selected option failed
        // and need to make it active again
        if shouldShowCard?(MessageRenderer.Message(chatMessage: message)) == false || isActive {
            action?(.refreshRow(index, in: messagesSection.index, animated: true))
        }
        action?(.setChoiceCardInputModeEnabled(isActive))
    }

    func isInteractableCustomCard(_ chatMessage: ChatMessage) -> Bool {
        let message = MessageRenderer.Message(chatMessage: chatMessage)
        return chatMessage.cardType == .customCard && (isInteractableCard?(message) ?? false)
    }
}
