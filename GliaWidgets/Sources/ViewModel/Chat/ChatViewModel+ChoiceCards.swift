import Foundation
import SalemoveSDK

extension ChatViewModel {
    func sendChoiceCardResponse(_ option: ChatChoiceCardOption, to messageId: String) {
        guard let option = option.asSingleChoiceOption() else { return }
        environment.sendSelectedOptionValue(option) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                guard
                    let selection = message.attachment?.selectedOption
                else { return }

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
        guard let index = messagesSection.items
            .enumerated()
            .first(where: {
                guard case .choiceCard(let message, _, _, _) = $0.element.kind
                else { return false }
                return message.id == choiceCardId
            })?.offset
        else { return }

        let choiceCard = messagesSection[index]

        guard case .choiceCard(
            let message,
            let showsImage,
            let imageUrl,
            _
        ) = choiceCard.kind else { return }

        message.attachment?.selectedOption = selection
        message.queueID = interactor.queueID
        let item = ChatItem(kind: .choiceCard(
            message,
            showsImage: showsImage,
            imageUrl: imageUrl,
            isActive: false
        ))

        messagesSection.replaceItem(at: index, with: item)
        action?(.refreshRow(index, in: messagesSection.index, animated: true))
        action?(.setChoiceCardInputModeEnabled(false))
        // Update stored choice card mode to be in
        // sync after response.
        isChoiceCardInputModeEnabled = false
    }
}
