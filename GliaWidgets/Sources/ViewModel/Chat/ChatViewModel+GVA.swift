import Foundation
import GliaCoreSDK

private extension String {
    static let gvaOptionUrlTargetModal = "modal"
    static let gvaOptionUrlTargetSelf = "self"
}

extension ChatViewModel {
    func gvaOptionAction(for option: GvaOption) -> Cmd {
        // If `option.destinationPdBroadcastEvent` is specified,
        // this is broadcast event button, which is not supported
        // on mobile. So an alert should be shown.
        // If option contains `url`, then it's URL Button,
        // otherwise it's Postback Button and option should be sent
        // to the server as `SingleChoiceOption`
        if option.destinationPdBroadcastEvent != nil {
            return broadcastEventButtonAction()
        } else if let urlString = option.url,
           let url = URL(string: urlString) {
            return urlButtonAction(url: url, urlTarget: option.urlTarget)
        } else {
            return postbackButtonAction(for: option)
        }
    }
}

private extension ChatViewModel {
    func urlButtonAction(url: URL, urlTarget: String?) -> Cmd {
        .init { [weak self] in
            guard let self = self else { return }

            let openUrl = { [weak self] url in
                guard let self = self else { return }
                guard self.environment.uiApplication.canOpenURL(url) else { return }
                self.environment.uiApplication.open(url)
            }

            switch url.scheme?.lowercased() {
            case URLScheme.tel.rawValue,
                URLScheme.mailto.rawValue,
                URLScheme.http.rawValue,
                URLScheme.https.rawValue:
                // "tel" ,"mailto" and "http(s)"-based links should be opened by UIApplication
                openUrl(url)

            default:
                if urlTarget == .gvaOptionUrlTargetModal ||
                    urlTarget == .gvaOptionUrlTargetSelf {
                    // if GvaOption.urlTarget is "modal" or "self", then button url is deeplink
                    // and should be opened by UIApplication, to provide integrator
                    // an ability to handle deeplinks they configured.
                    openUrl(url)
                } else {
                    return
                }
            }
        }
    }

    func postbackButtonAction(for option: GvaOption) -> Cmd {
        .init { [weak self] in
            guard let value = option.value else { return }
            let singleChoiceOption = SingleChoiceOption(text: option.text, value: value)
            self?.environment.sendSelectedOptionValue(singleChoiceOption) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(message):
                    let chatMessage = ChatMessage(with: message)
                    if let item = ChatItem(
                        with: chatMessage,
                        isCustomCardSupported: self.isCustomCardSupported
                    ) {
                        self.appendItem(item, to: self.messagesSection, animated: true)
                    }
                case .failure:
                    self.showAlert(
                        with: self.alertConfiguration.unexpectedError,
                        dismissed: nil
                    )
                }
            }
        }
    }

    func broadcastEventButtonAction() -> Cmd {
        .init { [weak self] in
            guard let self = self else { return }
            self.showAlert(
                with: self.alertConfiguration.unsupportedGvaBroadcastError,
                dismissed: nil
            )
        }
    }
}
