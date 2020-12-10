import SalemoveSDK

class Interactor {
    init(with conf: Configuration) throws {
        try configure(with: conf)
    }

    private func configure(with conf: Configuration) throws {
        try Salemove.sharedInstance.configure(appToken: conf.appToken)
        try Salemove.sharedInstance.configure(apiToken: conf.apiToken)
        try Salemove.sharedInstance.configure(environment: conf.environment.url)
        try Salemove.sharedInstance.configure(site: conf.site)
    }
}

extension Interactor: Interactable {
    var onScreenSharingOffer: ScreenshareOfferBlock {
        // When the operator asks for sharing the screen, supply the answer
        return { [unowned self] answer in
            //self.showRequestingView(request: "Possibility to share screen", answer: answer)
        }
    }

    var onMediaUpgradeOffer: MediaUgradeOfferBlock {
        // When the operator asks for audio/video, supply the answer
        return { [unowned self] _, answer in
            //self.showRequestingView(request: "Posibility to enable media", answer: answer)
        }
    }

    var onEngagementRequest: RequestOfferBlock {
        // Handle the incoming engagement request
        return { answer in
        // Supply the context that will be shown in the CoBrowsing area
            let context = VisitorContext(type: .page, url: "wwww.example.com")
            answer(context, true) {_, _ in }
        }
    }

    var onOperatorTypingStatusUpdate: OperatorTypingStatusUpdate {
        // Handle the operator typing status during an engagement
        return { _ in

        }
    }

    var onMessagesUpdated: MessagesUpdateBlock {
        // Handle the incoming messages list
        return { [unowned self] messages in

        }
    }

    var onVisitorScreenSharingStateChange: VisitorScreenSharingStateChange {
         // Handle the screen sharing state
        return { [unowned self] state, error in
            if let error = error {
                // Show or log the error
            } else {
                // Update the view by showing the stream
                DispatchQueue.main.async {
                }
            }
        }
    }

    var onAudioStreamAdded: AudioStreamAddedBlock {
        // Handle the incoming audio stream block
        return { [unowned self] stream, error in
            if let stream = stream {
                // Update the view by showing the stream
                DispatchQueue.main.async {

                }
            } else if let error = error {
                // Show or log the error
            }
        }
    }

    var onVideoStreamAdded: VideoStreamAddedBlock {
         // Handle the incoming video stream block
        return { [unowned self] stream, error in
            if let stream = stream {
                // Update the view by showing the stream
                DispatchQueue.main.async {

                }
            } else if let error = error {
                // Show or log the error
            }
        }
    }

    func start() {
        // Remove any spinners or activity indicators and proceed with the flow
        //endLoading()
    }

    func end() {
        // Remove any active sessions and do a cleanup and maybe dismiss the controller
        //cleanup()
    }

    func fail(with reason: String?) {
        // Handle the failing engagement request and maybe log the reason or show it to the user
        if let reason = reason {
            print(reason)
        }
        //cleanup()
    }

    func receive(message: Message) {
        // Update the messages that are coming from the SDK and show them to to the user
        //showMessage(message)
    }

    func fail(error: SalemoveError) {

    }
}
