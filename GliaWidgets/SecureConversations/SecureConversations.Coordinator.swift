import Foundation
import UIKit

extension SecureConversations {
    final class Coordinator: SubFlowCoordinator, FlowCoordinator {
        var delegate: ((DelegateEvent) -> Void)?
        private let viewFactory: ViewFactory
        private let navigationPresenter: NavigationPresenter
        private let environment: Environment
        private var viewModel: SecureConversations.WelcomeViewModel?
        private var selectedPickerController: SelectedPickerController?
        private var messagingInitialScreen: SecureConversations.InitialScreen

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

            return viewController
        }

        private func makeWelcomeViewModel() -> SecureConversations.WelcomeViewModel {
            SecureConversations.WelcomeViewModel(
                environment: .init(
                    welcomeStyle: viewFactory.theme.secureConversationsWelcome,
                    queueIds: environment.queueIds,
                    listQueues: environment.listQueues,
                    sendSecureMessage: environment.sendSecureMessage,
                    alertConfiguration: viewFactory.theme.alertConfiguration,
                    fileUploader: environment.createFileUploader(
                        SecureConversations.WelcomeViewModel.maximumUploads,
                        .init(
                            uploadFile: .toSecureMessaging(environment.uploadSecureFile),
                            fileManager: environment.fileManager,
                            data: environment.data,
                            date: environment.date,
                            gcd: environment.gcd,
                            localFileThumbnailQueue: environment.localFileThumbnailQueue,
                            uiImage: environment.uiImage,
                            uuid: environment.uuid
                        )
                    ),
                    uiApplication: environment.uiApplication,
                    createFileUploadListModel: environment.createFileUploadListModel,
                    fetchSiteConfigurations: environment.fetchSiteConfigurations,
                    startSocketObservation: environment.startSocketObservation,
                    stopSocketObservation: environment.stopSocketObservation
                ),
                availability: .init(
                    environment: .init(
                        listQueues: environment.listQueues,
                        queueIds: environment.queueIds,
                        isAuthenticated: environment.isAuthenticated
                    )
                )
            )
        }

        private func makeSecureConversationsWelcomeViewController() -> SecureConversations.WelcomeViewController {
            let viewModel = makeWelcomeViewModel()

            let controller = SecureConversations.WelcomeViewController(
                viewFactory: viewFactory,
                props: viewModel.props(),
                environment: .init(
                    gcd: environment.gcd,
                    uiScreen: environment.uiScreen,
                    notificationCenter: environment.notificationCenter
                )
            )

            viewModel.delegate = { [weak self, weak controller] event in
                self?.bindDelegate(to: event, controller: controller)
            }

            // Store view model, so that it would not be deallocated.
            self.viewModel = viewModel

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
            case let .mediaPickerRequested(originView, callback):
                controller?.presentPopover(
                    with: style.pickMediaStyle,
                    from: originView,
                    itemSelected: { [weak controller] kind in
                        controller?.dismiss(animated: true)
                        callback(kind)
                    }
                )
            case let .pickMedia(callback):
                presentMediaPickerController(
                    with: callback,
                    mediaSource: .library,
                    mediaTypes: [.image, .movie]
                )
            case let .takeMedia(callback):
                presentMediaPickerController(
                    with: callback,
                    mediaSource: .camera,
                    mediaTypes: [.image, .movie]
                )
            case let .pickFile(callback):
                presentFilePickerController(with: callback)
            case let .showAlert(conf, accessibilityIdentifier, dismissed):
                controller?.presentAlert(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier,
                    dismissed: dismissed
                )
            case let .showAlertAsView(conf, accessibilityIdentifier, dismissed):
                controller?.presentAlertAsView(
                    with: conf,
                    accessibilityIdentifier: accessibilityIdentifier,
                    dismissed: dismissed
                )
            case let .showSettingsAlert(conf, cancelled):
                controller?.presentSettingsAlert(
                    with: conf, cancelled: cancelled
                )
            case .transcriptRequested:
                navigateToTranscript()
            }
        }

        func presentSecureConversationsConfirmationViewController() {
            let viewModel = SecureConversations.ConfirmationViewModel(
                environment: .init(
                    confirmationStyle: viewFactory.theme.secureConversationsConfirmation
                )
            )

            let controller = SecureConversations.ConfirmationViewController(
                viewModel: viewModel,
                viewFactory: viewFactory,
                props: viewModel.props()
            )

            viewModel.delegate = { [weak self, weak controller] event in
                switch event {
                case .closeTapped:
                    self?.delegate?(.closeTapped(.doNotPresentSurvey))
                // Bind changes in view model to view controller.
                case let .renderProps(props):
                    controller?.props = props
                case .chatTranscriptScreenRequested:
                    self?.navigateToTranscript()
                }
            }

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

        private func presentFilePickerController(with pickerEvent: Command<FilePickerEvent>) {
            let observable = ObservableValue<FilePickerEvent>(with: .none)
            observable.addObserver(self, update: { event, _ in pickerEvent(event) })
            let viewModel = FilePickerViewModel(pickerEvent: observable)
            viewModel.delegate = { [weak self] event in
                switch event {
                case .finished:
                    self?.selectedPickerController = nil
                }
            }
            let controller = FilePickerController(viewModel: viewModel)
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
            screenShareHandler: environment.screenShareHandler,
            isWindowVisible: environment.isWindowVisible,
            startAction: .startEngagement,
            environment: .init(
                fetchFile: environment.fetchFile,
                sendSelectedOptionValue: environment.sendSelectedOptionValue,
                uploadFileToEngagement: environment.uploadFileToEngagement,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                localFileThumbnailQueue: environment.localFileThumbnailQueue,
                uiImage: environment.uiImage,
                createFileDownload: environment.createFileDownload,
                fromHistory: environment.loadChatMessagesFromHistory,
                fetchSiteConfigurations: environment.fetchSiteConfigurations,
                getCurrentEngagement: environment.getCurrentEngagement,
                submitSurveyAnswer: environment.submitSurveyAnswer,
                uuid: environment.uuid,
                uiApplication: environment.uiApplication,
                fetchChatHistory: environment.fetchChatHistory,
                createFileUploadListModel: environment.createFileUploadListModel,
                sendSecureMessage: environment.sendSecureMessage,
                queueIds: environment.queueIds,
                listQueues: environment.listQueues,
                secureUploadFile: environment.uploadSecureFile,
                getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
                messagesWithUnreadCountLoaderScheduler: environment.messagesWithUnreadCountLoaderScheduler,
                secureMarkMessagesAsRead: environment.secureMarkMessagesAsRead,
                downloadSecureFile: environment.downloadSecureFile,
                isAuthenticated: environment.isAuthenticated,
                interactor: environment.interactor,
                startSocketObservation: environment.startSocketObservation,
                stopSocketObservation: environment.stopSocketObservation
            ),
            startWithSecureTranscriptFlow: true
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
    struct Environment {
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
        var createFileUploader: FileUploader.Create
        var uploadSecureFile: CoreSdkClient.SecureConversationsUploadFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var viewFactory: ViewFactory
        var fetchFile: CoreSdkClient.FetchFile
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var chatCall: ObservableValue<Call?>
        var unreadMessages: ObservableValue<Int>
        var showsCallBubble: Bool
        var screenShareHandler: ScreenShareHandler
        var isWindowVisible: ObservableValue<Bool>
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var interactor: Interactor
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var isAuthenticated: () -> Bool
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
    }

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
