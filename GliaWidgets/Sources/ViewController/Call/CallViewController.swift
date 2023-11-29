import UIKit

final class CallViewController: EngagementViewController {
    private let viewModel: CallViewModel
    private let environment: Environment

    init(viewModel: CallViewModel, viewFactory: ViewFactory, environment: Environment) {
        self.environment = environment
        self.viewModel = viewModel
        super.init(viewModel: viewModel, viewFactory: viewFactory)
    }

    deinit {
        environment.log.prefixed(Self.self).info("Destroy Call screen")
        environment.notificationCenter.removeObserver(self)
    }

    override public func loadView() {
        let view = viewFactory.makeCallView(
            endCmd: .init { [weak self] in self?.viewModel.event(.closeTapped) },
            closeCmd: .init { [weak self] in self?.viewModel.event(.closeTapped) },
            endScreenshareCmd: .init { [weak self] in self?.viewModel.event(.endScreenSharingTapped) },
            backCmd: .init { [weak self] in self?.viewModel.event(.backTapped) }
        )
        self.view = view

        bind(viewModel: viewModel, to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.event(.viewDidLoad)

        environment.notificationCenter.addObserver(
            self,
            selector: #selector(CallViewController.deviceDidRotate),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return viewFactory.theme.call.preferredStatusBarStyle }

    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard let view = view as? CallView else { return }
        view.willRotate(to: orientation, duration: duration)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let view = view as? CallView else { return }
        view.checkBarsOrientation()
    }
}

// MARK: - Private

private extension CallViewController {
    @objc
    func deviceDidRotate() {
        guard let view = view as? CallView else { return }
        view.didRotate()
    }

    func bind(viewModel: CallViewModel, to view: CallView) {
        view.header.showBackButton()
        view.header.showCloseButton()

        view.callButtonTapped = { [weak viewModel] button in
            viewModel?.event(.callButtonTapped(.init(with: button)))
        }

        self.viewModel.action = { [weak self] action in
            guard let self else { return }
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
            case .setTitle(let title):
                view.header.props = Self.buildNewHeaderProps(newTitle: title, props: view.header.props)
            case .setOperatorName(let name):
                view.operatorNameLabel.text = name
                view.operatorNameLabel.accessibilityLabel = name
            case .setCallDurationText(let text):
                view.callDuration = text
            case .showButtons(let buttons):
                let buttons = buttons.map { CallButton.Kind(with: $0) }
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
            case .setVisitorOnHold(let isOnHold):
                view.isVisitrOnHold = isOnHold
            case .transferring:
                view.setConnectState(.transferring, animated: true)
            case .showSnackBarView:
                self.showSnackBarView()
            }
        }
    }

    static func buildNewHeaderProps(newTitle: String, props: Header.Props) -> Header.Props {
        Header.Props(
            title: newTitle,
            effect: props.effect,
            endButton: props.endButton,
            backButton: props.backButton,
            closeButton: props.closeButton,
            endScreenshareButton: props.endScreenshareButton,
            style: props.style
        )
    }

    func showSnackBarView() {
        let style = viewFactory.theme.invertedSnackBar
        snackBar.present(
            text: style.text,
            style: style,
            for: self,
            bottomOffset: -100,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd
        )
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

extension CallViewController {
    struct Environment {
        var notificationCenter: FoundationBased.NotificationCenter
        var log: CoreSdkClient.Logger
        var timerProviding: FoundationBased.Timer.Providing
        var gcd: GCD
    }
}
