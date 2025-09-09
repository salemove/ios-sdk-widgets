import Foundation

private extension String {
    static let gvaOptionUrlTargetModal = "modal"
    static let gvaOptionUrlTargetSelf = "self"
}

extension ChatViewModel {
    func quickReplyOption(_ gvaOption: GvaOption) -> QuickReplyButtonCell.Props {
        let action = Cmd { [weak self] in
            self?.gvaOptionAction(for: gvaOption)()
            self?.action?(.quickReplyPropsUpdated(.hidden))
        }
        return .init(
            title: gvaOption.text,
            action: action
        )
    }

    func gvaOptionAction(for option: GvaOption) -> Cmd {
        // If `option.destinationPdBroadcastEvent` is specified,
        // this is broadcast event button, which is not supported
        // on mobile. So an alert should be shown.
        if option.destinationPdBroadcastEvent != nil {
            return broadcastEventButtonAction()
        }

        // If option contains `url`, then it's URL Button
        if let urlString = option.url, let url = URL(string: urlString) {
            return urlButtonAction(url: url, urlTarget: option.urlTarget)
        }

        // Otherwise it's Postback Button and option should be sent
        // to the server as `SingleChoiceOption`
        return postbackButtonAction(for: option)
    }

    func postbackButtonAction(for option: GvaOption) -> Cmd {
        .init { [weak self] in
            guard let self else { return }

            environment.openTelemetry.logger.i(.chatScreenGvaMessageAction) {
                $0[.actionType] = .string(OtelGvaActionTypes.postBack.rawValue)
            }

            let attachment = CoreSdkClient.Attachment(
                type: .singleChoiceResponse,
                selectedOption: option.value,
                options: nil,
                files: nil,
                imageUrl: nil
            )

            let payload = self.environment.createSendMessagePayload(option.text, attachment)
            let outgoingMessage = OutgoingMessage(payload: payload)

            switch self.interactor.state {
            case .enqueued:
                self.handle(pendingMessage: outgoingMessage)

            case .engaged where shouldForceEnqueueing, .enqueueing, .ended, .none:
                self.handle(pendingMessage: outgoingMessage)
                self.enqueue(engagementKind: .chat, replaceExisting: false)

            case .engaged:
                self.sendMessage(outgoingMessage)
            }
        }
    }
}

private extension ChatViewModel {
    func urlButtonAction(url: URL, urlTarget: String?) -> Cmd {
        .init { [weak self] in
            guard let self else { return }

            let openUrl = { [weak self] url in
                guard let self = self else { return }
                guard self.environment.uiApplication.canOpenURL(url) else { return }
                self.environment.uiApplication.open(url)
            }

            let logGvaAction: (OtelGvaActionTypes) -> Void = { [weak self] actionType in
                self?.environment.openTelemetry.logger.i(.chatScreenGvaMessageAction) {
                    $0[.actionType] = .string(actionType.rawValue)
                }
            }

            // "tel" ,"mailto" and "http(s)"-based links should be opened by UIApplication
            switch url.scheme?.lowercased() {
            case URLScheme.tel.rawValue:
                logGvaAction(.phone)
                openUrl(url)
            case URLScheme.mailto.rawValue:
                logGvaAction(.email)
                openUrl(url)
            case URLScheme.http.rawValue, URLScheme.https.rawValue:
                logGvaAction(.url)
                openUrl(url)

            default:
                // if GvaOption.urlTarget is "modal" or "self", then button url is deeplink
                // and should be opened by UIApplication, to provide integrator
                // an ability to handle deeplinks they configured.
                switch urlTarget {
                case String.gvaOptionUrlTargetSelf:
                    // In case of urlTarget "self" we need to minimize Glia UI
                    self.delegate?(.minimize)
                    logGvaAction(.url)
                    openUrl(url)
                case String.gvaOptionUrlTargetModal:
                    logGvaAction(.url)
                    openUrl(url)
                default:
                    return
                }
            }
        }
    }

    func broadcastEventButtonAction() -> Cmd {
        .init { [weak self] in
            guard let self else { return }
            self.engagementAction?(.showAlert(.unsupportedGvaBroadcastError()))
        }
    }

    func sendMessage(_ outgoingMessage: OutgoingMessage) {
        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        interactor.send(messagePayload: outgoingMessage.payload) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(message):
                if !self.hasReceivedMessage(messageId: message.id) {
                    self.registerReceivedMessage(messageId: message.id)
                    self.replace(
                        outgoingMessage,
                        uploads: [],
                        with: message,
                        in: self.messagesSection
                    )
                }
            case .failure:
                self.markMessageAsFailed(
                    outgoingMessage,
                    in: self.messagesSection
                )
            }
        }
    }
}
