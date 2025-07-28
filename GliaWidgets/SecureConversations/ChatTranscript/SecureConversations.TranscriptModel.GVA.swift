import Foundation

private extension String {
    static let gvaOptionUrlTargetModal = "modal"
    static let gvaOptionUrlTargetSelf = "self"
}

extension SecureConversations.TranscriptModel {
    func quickReplyOption(_ gvaOption: GvaOption) -> QuickReplyButtonCell.Props {
        let action = AsyncCmd { [weak self] in
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
}

// MARK: - Private
private extension SecureConversations.TranscriptModel {
    func postbackButtonAction(for option: GvaOption) -> Cmd {
        .init { [weak self] in
            self?.environment.openTelemetry.logger.i(.chatScreenGvaMessageAction) {
                $0[.actionType] = .string(OtelGvaActionTypes.postBack.rawValue)
            }
            self?.sendGvaOption(option)
        }
    }

    func urlButtonAction(url: URL, urlTarget: String?) -> Cmd {
        .init { [weak self] in
            guard let self else { return }

            let openUrl = { [weak self] url in
                guard let self else { return }
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
            self.environment.openTelemetry.logger.i(.chatScreenGvaMessageAction) {
                $0[.actionType] = .string(OtelGvaActionTypes.broadcastEvent.rawValue)
            }
            self.engagementAction?(.showAlert(.unsupportedGvaBroadcastError()))
        }
    }

    func sendGvaOption(_ option: GvaOption) {
        let attachment = CoreSdkClient.Attachment(
            type: .singleChoiceResponse,
            selectedOption: option.value,
            options: nil,
            files: nil,
            imageUrl: nil
        )

        let payload = environment.createSendMessagePayload(option.text, attachment)
        let outgoingMessage = OutgoingMessage(payload: payload)

        appendItem(
            .init(kind: .outgoingMessage(outgoingMessage, error: nil)),
            to: pendingSection,
            animated: true
        )

        _ = environment.secureConversations.sendMessagePayload(
            outgoingMessage.payload,
            environment.queueIds
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(message):
                self.replace(
                    outgoingMessage,
                    uploads: [],
                    with: message,
                    in: self.pendingSection
                )
            case .failure:
                self.markMessageAsFailed(
                    outgoingMessage,
                    in: self.pendingSection
                )
            }
        }
    }
}
