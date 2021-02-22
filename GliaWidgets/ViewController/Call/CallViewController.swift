import UIKit

class CallViewController: EngagementViewController, MediaUpgradePresenter {
    private let viewModel: CallViewModel

    init(viewModel: CallViewModel,
         viewFactory: ViewFactory) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, viewFactory: viewFactory)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        let view = viewFactory.makeCallView()
        self.view = view
        bind(viewModel: viewModel, to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return viewFactory.theme.call.preferredStatusBarStyle }

    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard let view = view as? CallView else { return }
        view.willRotate(to: orientation, duration: duration)
    }

    // swiftlint:disable function_body_length
    private func bind(viewModel: CallViewModel, to view: CallView) {
        showBackButton(with: viewFactory.theme.call.backButton, in: view.header)
        showCloseButton(with: viewFactory.theme.call.closeButton, in: view.header)

        view.callButtonTapped = { viewModel.event(.callButtonTapped(.init(with: $0))) }

        viewModel.action = { action in
            switch action {
            case .queue:
                view.setConnectState(.queue, animated: false)
            case .connecting(name: let name, imageUrl: let imageUrl):
                view.setConnectState(.connecting(name: name, imageUrl: imageUrl), animated: true)
                view.connectView.operatorView.setSize(.normal, animated: true)
            case .connected(name: let name, imageUrl: let imageUrl):
                view.setConnectState(.connected(name: name, imageUrl: imageUrl), animated: true)
                view.connectView.operatorView.setSize(.large, animated: true)
            case .setTopTextHidden(let hidden):
                view.topLabel.isHidden = hidden
            case .setBottomTextHidden(let hidden):
                view.bottomLabel.isHidden = hidden
            case .switchToVideoMode:
                view.switchTo(.video)
            case .switchToUpgradeMode:
                view.switchTo(.upgrading)
            case .showEndButton:
                let rightItem = ActionButton(with: self.viewFactory.theme.chat.endButton)
                rightItem.tap = { viewModel.event(.closeTapped) }
                view.header.setRightItem(rightItem, animated: true)
            case .setTitle(let title):
                view.header.title = title
            case .setOperatorName(let name):
                view.operatorNameLabel.text = name
            case .setCallDurationText(let text):
                view.durationLabel.text = text
                view.connectView.statusView.setSecondText(text, animated: false)
            case .showButtons(let buttons):
                let buttons = buttons.map({ CallButton.Kind(with: $0) })
                view.buttonBar.visibleButtons = buttons
            case .setButtonEnabled(let button, enabled: let enabled):
                let button = CallButton.Kind(with: button)
                view.buttonBar.setButton(button, enabled: enabled)
            case .setButtonState(let button, state: let state):
                let button = CallButton.Kind(with: button)
                let state = CallButton.State(with: state)
                view.buttonBar.setButton(button, state: state)
            case .setButtonBadge(let button, itemCount: let itemCount):
                let button = CallButton.Kind(with: button)
                view.buttonBar.setButton(button, badgeItemCount: itemCount)
            case .offerMediaUpgrade(let conf, accepted: let accepted, declined: let declined):
                self.offerMediaUpgrade(with: conf, accepted: accepted, declined: declined)
            case .setRemoteVideo(let streamView):
                view.remoteVideoView.streamView = streamView
            case .setLocalVideo(let streamView):
                view.localVideoView.streamView = streamView
            }
        }
    }
}

private extension CallViewModel.CallButton {
    init(with kind: CallButton.Kind) {
        switch kind {
        case .chat:
            self = .chat
        case .video:
            self = .video
        case .mute:
            self = .mute
        case .speaker:
            self = .speaker
        case .minimize:
            self = .minimize
        }
    }
}

private extension CallButton.Kind {
    init(with button: CallViewModel.CallButton) {
        switch button {
        case .chat:
            self = .chat
        case .video:
            self = .video
        case .mute:
            self = .mute
        case .speaker:
            self = .speaker
        case .minimize:
            self = .minimize
        }
    }
}

private extension CallButton.State {
    init(with state: CallViewModel.CallButtonState) {
        switch state {
        case .active:
            self = .active
        case .inactive:
            self = .inactive
        }
    }
}
