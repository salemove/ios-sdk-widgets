import Foundation
import GliaCoreSDK

// MARK: Custom cards

extension ChatViewModel {
    func sendSelectedCustomCardOption(
        _ option: HtmlMetadata.Option,
        for messageId: MessageRenderer.Message.Identifier
    ) {
        guard case .engaged = interactor.state else { return }
        let attachment = CoreSdkClient.Attachment(
            type: .singleChoiceResponse,
            selectedOption: option.value,
            options: nil,
            files: nil,
            imageUrl: nil
        )

        let payload = environment.createSendMessagePayload(option.text, nil)
        let outgoingMessage = OutgoingMessage(payload: payload)

        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        let success: (CoreSdkClient.Message) -> Void = { [weak self] message in
            guard let self = self else { return }

            self.updateCustomCard(
                messageId: messageId,
                selectedOption: option,
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

        let failure: (CoreSdkClient.SalemoveError) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.updateCustomCard(
                messageId: messageId,
                selectedOption: nil,
                isActive: true
            )
            self.showAlert(
                with: self.alertConfiguration.unexpectedError,
                dismissed: nil
            )
        }

        let messagePayload = environment.createSendMessagePayload(option.text, attachment)

        interactor.send(messagePayload: messagePayload) { result in
            switch result {
            case let .success(message):
                success(message)
            case let .failure(error):
                failure(error)
            }
        }
    }

    private func updateCustomCard(
        messageId: MessageRenderer.Message.Identifier,
        selectedOption: HtmlMetadata.Option?,
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

        message.attachment?.selectedOption = selectedOption?.value
        message.queueID = interactor.queueID
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
