import Foundation
import UIKit

extension SecureConversations {
    final class Coordinator: SubFlowCoordinator, FlowCoordinator {
        var delegate: ((DelegateEvent) -> Void)?
        private let viewFactory: ViewFactory
        private let navigationPresenter: NavigationPresenter
        private let environment: Environment
        private(set) var selectedPickerController: SelectedPickerController?
        private var messagingInitialScreen: SecureConversations.InitialScreen

        deinit {
            environment.stopSocketObservation()
        }

        init(
            messagingInitialScreen: SecureConversations.InitialScreen,
            viewFactory: ViewFactory,
            navigationPresenter: NavigationPresenter,
            environment: Environment
        ) {
            self.messagingInitialScreen = messagingInitialScreen
            self.viewFactory = viewFactory
            self.navigationPresenter = navigationPresenter
            self.environment = environment
        }

        func start() -> UIViewController {
            var viewController: UIViewController

            switch messagingInitialScreen {
            case .chatTranscript:
                viewController = navigateToTranscript()
            default:
                viewController = makeSecureConversationsWelcomeViewController()
            }

            environment.startSocketObservation()
            return viewController
        }

        private func makeWelcomeViewModel() -> SecureConversations.WelcomeViewModel {
            SecureConversations.WelcomeViewModel(
                environment: .create(
                    with: environment,
                    viewFactory: viewFactory
                ),
                availability: .init(environment: .create(with: environment))
            )
        }

        private func makeSecureConversationsWelcomeViewController() -> SecureConversations.WelcomeViewController {
            environment.log.prefixed(Self.self).info("Create Message Center screen")
            let viewModel = makeWelcomeViewModel()

            let controller = SecureConversations.WelcomeViewController(
                viewFactory: viewFactory,
                viewModel: viewModel,
                props: viewModel.props(),
                environment: .create(with: environment)
            )

            viewModel.delegate = { [weak self, weak controller] event in
                self?.bindDelegate(to: event, controller: controller)
            }

            return controller
        }

        private func bindDelegate(
            to event: WelcomeViewModel.DelegateEvent,
            controller: WelcomeViewController?
        ) {
            let style = viewFactory.theme.secureConversationsWelcomeStyle
            switch event {
            case .backTapped:
                delegate?(.backTapped)
            case .closeTapped:
                delegate?(.closeTapped(.doNotPresentSurvey))
            // Bind changes in view model to view controller.
            case let .renderProps(props):
                controller?.props = props
            case .confirmationScreenRequested:
                presentSecureConversationsConfirmationViewController()
            case let .mediaPickerRequested(originView, options, callback):
                controller?.presentPopover(
                    with: style.pickMediaStyle,
                    from: originView,
                    options: options,
                    itemSelected: { [weak controller] kind in
                        controller?.dismiss(animated: true)
                        callback(kind)
                    }
                )
            case let .pickMedia(callback, mediaTypes):
                presentMediaPickerController(
                    with: callback,
                    mediaSource: .library,
                    mediaTypes: mediaTypes
                )
            case let .takeMedia(callback, mediaTypes):
                presentMediaPickerController(
                    with: callback,
                    mediaSource: .camera,
                    mediaTypes: mediaTypes
                )
            case let .pickFile(callback, fileTypes):
                presentFilePickerController(with: callback, fileTypes: fileTypes)
            case .transcriptRequested:
                navigateToTranscript()
            case let .showAlert(type):
                guard let controller else { return }
                environment.alertManager.present(
                    in: .root(controller),
                    as: type
                )
            }
        }

        func presentSecureConversationsConfirmationViewController() {
            environment.log.prefixed(Self.self).info("Show Message Center Confirmation screen")
            let model = SecureConversations.ConfirmationViewSwiftUI.Model(
                environment: .create(with: environment),
                style: viewFactory.theme.secureConversationsConfirmation,
                delegate: { [weak self] event in
                    switch event {
                    case .closeTapped:
                        self?.delegate?(.closeTapped(.doNotPresentSurvey))
                    case .chatTranscriptScreenRequested:
                        self?.navigateToTranscript()
                    }
                }
            )

            let controller = SecureConversations.ConfirmationViewController(model: model)

            self.navigationPresenter.push(
                controller,
                animated: true,
                replacingLast: true
            )
        }

        private func presentMediaPickerController(
            with pickerEvent: Command<MediaPickerEvent>,
            mediaSource: MediaPickerViewModel.MediaSource,
            mediaTypes: [MediaPickerViewModel.MediaType]
        ) {
            let observable = ObservableValue<MediaPickerEvent>(with: .none)
            observable.addObserver(self, update: { newValue, _ in pickerEvent(newValue) })
            let viewModel = MediaPickerViewModel(
                pickerEvent: observable,
                mediaSource: mediaSource,
                mediaTypes: mediaTypes
            )

            viewModel.delegate = { [weak self] event in
                switch event {
                case .finished:
                    self?.selectedPickerController = nil
                }
            }

            let controller = MediaPickerController(viewModel: viewModel)
            controller.viewController { [weak self] viewController in
                self?.navigationPresenter.present(viewController)
            }
            // Keep strong reference, otherwise
            // `controller` will be deallocted, resulting in
            // event not being sent.
            self.selectedPickerController = .mediaPickerController(controller)
        }

        private func presentFilePickerController(with pickerEvent: Command<FilePickerEvent>, fileTypes: FilePickerViewModel.FileTypes) {
            let observable = ObservableValue<FilePickerEvent>(with: .none)
            observable.addObserver(self, update: { event, _ in pickerEvent(event) })
            let viewModel = FilePickerViewModel(pickerEvent: observable, allowedFiles: fileTypes)
            viewModel.delegate = { [weak self] event in
                switch event {
                case .finished:
                    self?.selectedPickerController = nil
                }
            }
            let controller = FilePickerController(
                viewModel: viewModel,
                environment: .create(with: environment)
            )
            // Keep strong reference, otherwise
            // `controller` will be deallocted, resulting in
            // event not being sent.
            self.selectedPickerController = .filePickerController(controller)

            navigationPresenter.present(controller.viewController)
        }
    }
}

// Chat transcript
extension SecureConversations.Coordinator {
    @discardableResult
    private func navigateToTranscript() -> UIViewController {
        let coordinator = ChatCoordinator(
            interactor: environment.interactor,
            viewFactory: environment.viewFactory,
            navigationPresenter: navigationPresenter,
            call: environment.chatCall,
            unreadMessages: environment.unreadMessages,
            showsCallBubble: environment.showsCallBubble,
            isWindowVisible: environment.isWindowVisible,
            startAction: .startEngagement,
            environment: .create(with: environment),
            startWithSecureTranscriptFlow: true,
            skipTransferredSCHandling: false
        )

        coordinator.delegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.backTapped)
            case .finished:
                self?.delegate?(.closeTapped(.presentSurvey))
            default:
                self?.delegate?(.chat(event))
            }
        }

        pushCoordinator(coordinator)

        let viewController = coordinator.start()
        navigationPresenter.push(viewController, replacingLast: true)

        return viewController
    }
}

extension SecureConversations.Coordinator {
    enum DelegateEvent {
        case backTapped
        case closeTapped(SurveyPresentation)
        case chat(ChatCoordinator.DelegateEvent)

        enum SurveyPresentation {
            case presentSurvey
            case doNotPresentSurvey
        }
    }
}

extension SecureConversations.Coordinator {
    enum SelectedPickerController {
        case filePickerController(FilePickerController)
        case mediaPickerController(MediaPickerController)
    }
}

#if DEBUG
extension SecureConversations.Coordinator {
    var coordinatorEnvironment: Environment {
        environment
    }
}
#endif
