import UIKit

class CallCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case openLink(WebViewController.Link)
        case engaged(operatorImageUrl: String?)
        case visitorOnHoldUpdated(isOnHold: Bool)
        case chat
        case minimize
        case finished
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let interactor: Interactor
    private let viewFactory: ViewFactory
    private let navigationPresenter: NavigationPresenter
    private let call: Call
    private let unreadMessages: ObservableValue<Int>
    private let screenShareHandler: ScreenShareHandler
    private let startAction: CallViewModel.StartAction
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        navigationPresenter: NavigationPresenter,
        call: Call,
        unreadMessages: ObservableValue<Int>,
        screenShareHandler: ScreenShareHandler,
        startAction: CallViewModel.StartAction,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.navigationPresenter = navigationPresenter
        self.call = call
        self.unreadMessages = unreadMessages
        self.screenShareHandler = screenShareHandler
        self.startAction = startAction
        self.environment = environment
    }

    func start() -> CallViewController {
        let viewController = makeCallViewController(
            call: call,
            startAction: startAction
        )
        return viewController
    }
}

// MARK: - Private

private extension CallCoordinator {
    func makeCallViewController(
        call: Call,
        startAction: CallViewModel.StartAction
    ) -> CallViewController {
        let viewModel = CallViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            environment: .init(
                fetchFile: environment.fetchFile,
                downloadSecureFile: environment.downloadSecureFile,
                uploadFileToEngagement: environment.uploadFileToEngagement,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                gcd: environment.gcd,
                uiScreen: environment.uiScreen,
                createThumbnailGenerator: environment.createThumbnailGenerator,
                createFileDownload: environment.createFileDownload,
                loadChatMessagesFromHistory: environment.fromHistory,
                fetchSiteConfigurations: environment.fetchSiteConfigurations,
                getCurrentEngagement: environment.getCurrentEngagement,
                timerProviding: environment.timerProviding,
                uuid: environment.uuid,
                uiApplication: environment.uiApplication,
                fetchChatHistory: environment.fetchChatHistory,
                fileUploadListStyle: viewFactory.theme.chatStyle.messageEntry.uploadList,
                createFileUploadListModel: environment.createFileUploadListModel,
                createSendMessagePayload: environment.createSendMessagePayload,
                proximityManager: environment.proximityManager
            ),
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        viewModel.engagementDelegate = { [weak self] event in
            self?.handleEngagementViewModelEvent(event)
        }
        viewModel.delegate = { [weak self] event in
            self?.handleCallViewModelEvent(event)
        }
        return CallViewController(
            viewModel: viewModel,
            environment: .init(
                viewFactory: viewFactory,
                notificationCenter: environment.notificationCenter,
                timerProviding: environment.timerProviding,
                gcd: environment.gcd,
                snackBar: environment.snackBar
            )
        )
    }

    func handleEngagementViewModelEvent(_ event: EngagementViewModel.DelegateEvent) {
        switch event {
        case .back:
            delegate?(.back)
        case let .openLink(link):
            delegate?(.openLink(link))
        case .engaged(let url):
            delegate?(.engaged(operatorImageUrl: url))
        case .finished:
            delegate?(.finished)
        }
    }

    func handleCallViewModelEvent(_ event: CallViewModel.DelegateEvent) {
        switch event {
        case .chat:
            delegate?(.chat)
        case .minimize:
            delegate?(.minimize)
        case .visitorOnHoldUpdated(let isOnHold):
            delegate?(.visitorOnHoldUpdated(isOnHold: isOnHold))
        }
    }
}

extension CallCoordinator {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
        var downloadSecureFile: CoreSdkClient.DownloadSecureFile
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var createThumbnailGenerator: () -> QuickLookBased.ThumbnailGenerator
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var timerProviding: FoundationBased.Timer.Providing
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
        var uuid: () -> UUID
        var uiApplication: UIKitBased.UIApplication
        var uiScreen: UIKitBased.UIScreen
        var notificationCenter: FoundationBased.NotificationCenter
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
        var proximityManager: ProximityManager
        var snackBar: SnackBar
    }
}
