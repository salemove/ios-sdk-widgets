import Foundation

extension ChatViewModel {
    @MainActor
    func sendChoiceCardResponse(_ option: ChatChoiceCardOption, to messageId: String) async {
        guard let text = option.text else { return }
        let attachment = CoreSdkClient.Attachment(
            type: .singleChoiceResponse,
            selectedOption: option.value,
            options: nil,
            files: nil,
            imageUrl: nil
        )

        let payload = environment.createSendMessagePayload(text, attachment)
        registerReceivedMessage(messageId: payload.messageId.rawValue)

        let outgoingMessage = OutgoingMessage(
            payload: payload,
            relation: .singleChoice(messageId: .init(rawValue: messageId))
        )

        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        do {
            let message = try await interactor.send(messagePayload: payload)
            onSuccessSendChoiceCardResponse(message: message, messageId: messageId)
        } catch {
            onFailureSendChoiceCardResponse(outgoingMessage: outgoingMessage)
        }
    }

    @MainActor
    func onSuccessSendChoiceCardResponse(
        message: CoreSdkClient.Message,
        messageId: String
    ) {
        let selection = message.content
        self.respond(to: messageId, with: selection)
    }

    @MainActor
    func onFailureSendChoiceCardResponse(outgoingMessage: OutgoingMessage) {
        self.markMessageAsFailed(
            outgoingMessage,
            in: self.messagesSection
        )
    }

    func respond(to choiceCardId: String, with selection: String?) {
        // In the case of upgrading a secure conversation to a live chat,
        // there's a bug (MSG-483) that sends the welcome message web socket event before the
        // start engagement event. This means that we display it in the `pendingSection`
        // instead the `messagesSection` because the `TranscriptModel` is in charge of
        // it instead of the `ChatViewModel`. Thus, this method wouldn't find the choice card
        // and it would be displayed as active forever. Here we search for the choice card
        // both in the `pendingSection` and on the `messagesSection`. When MSG-483 is fixed, we can
        // test if this can be reverted.
        guard let (index, section) = searchForChoiceCard(in: messagesSection, choiceCardId: choiceCardId) ??
                searchForChoiceCard(in: pendingSection, choiceCardId: choiceCardId) else { return }

        let choiceCard = section[index]

        guard case .choiceCard(
            let message,
            _,
            _,
            _
        ) = choiceCard.kind else { return }

        message.attachment?.selectedOption = selection

        let item = ChatItem(
            kind: .operatorMessage(
                ChatMessage(
                    id: message.id,
                    operator: message.operator,
                    sender: message.sender,
                    content: message.content,
                    attachment: message.attachment,
                    downloads: message.downloads
                ),
                showsImage: false,
                imageUrl: message.operator?.pictureUrl
            )
        )
        section.replaceItem(at: index, with: item)
        action?(.refreshRow(index, in: section.index, animated: true))
        action?(.setChoiceCardInputModeEnabled(false))
        // Update stored choice card mode to be in
        // sync after response.
        isChoiceCardInputModeEnabled = false
        action?(.refreshAll)
    }

    private func searchForChoiceCard(in section: Section<ChatItem>, choiceCardId: String) -> (Int, Section<ChatItem>)? {
        guard let index = section.items
            .enumerated()
            .first(where: {
                guard case .choiceCard(let message, _, _, _) = $0.element.kind
                else { return false }
                return message.id == choiceCardId
            })?.offset
        else {
            return nil
        }

        return (index, section)
    }
}
