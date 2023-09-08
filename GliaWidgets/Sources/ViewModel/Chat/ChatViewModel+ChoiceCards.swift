import Foundation
import GliaCoreSDK

extension ChatViewModel {
    func sendChoiceCardResponse(_ option: ChatChoiceCardOption, to messageId: String) {
        guard let text = option.text else { return }
        let attachment = CoreSdkClient.Attachment(
            type: .singleChoiceResponse,
            selectedOption: option.value,
            options: nil,
            files: nil,
            imageUrl: nil
        )

        let payload = self.environment.createSendMessagePayload(text, attachment)
        registerReceivedMessage(messageId: payload.messageId.rawValue)

        interactor.send(messagePayload: payload) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                let selection = message.content
                self.respond(to: messageId, with: selection)
            case .failure:
                self.showAlert(
                    with: self.alertConfiguration.unexpectedError,
                    dismissed: nil
                )
            }
        }
    }

    private func respond(to choiceCardId: String, with selection: String?) {
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
        message.queueID = interactor.queueID

        let item = ChatItem(
            kind: .visitorMessage(
                ChatMessage(
                    id: message.id,
                    queueID: message.queueID,
                    operator: message.operator,
                    sender: message.sender,
                    content: message.attachment?.selectedOption ?? "",
                    attachment: message.attachment,
                    downloads: message.downloads
                ),
                status: nil
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
