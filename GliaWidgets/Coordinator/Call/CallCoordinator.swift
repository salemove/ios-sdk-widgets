import UIKit

class CallCoordinator: SubFlowCoordinator, FlowCoordinator {
    enum DelegateEvent {
        case back
        case engaged(operatorImageUrl: String?)
        case visitorOnHoldUpdated(isOnHold: Bool)
        case chat
        case minimize
        case finished(String?, CoreSdkClient.Survey?)
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

    private func makeCallViewController(
        call: Call,
        startAction: CallViewModel.StartAction
    ) -> CallViewController {
        let viewModel = CallViewModel(
            interactor: interactor,
            alertConfiguration: viewFactory.theme.alertConfiguration,
            screenShareHandler: screenShareHandler,
            environment: .init(
                chatStorage: environment.chatStorage,
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
                fromHistory: environment.fromHistory,
                fetchSiteConfigurations: environment.fetchSiteConfigurations,
                getCurrentEngagement: environment.getCurrentEngagement,
                timerProviding: .live
            ),
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        viewModel.engagementDelegate = { [weak self] event in
            switch event {
            case .back:
                self?.delegate?(.back)
            case .engaged(operatorImageUrl: let url):
                self?.delegate?(.engaged(operatorImageUrl: url))
            case let .finished(engagementId, survey):
                self?.delegate?(.finished(engagementId, survey))
            }
        }
        viewModel.delegate = { [weak self] event in
            switch event {
            case .chat:
                self?.delegate?(.chat)
            case .minimize:
                self?.delegate?(.minimize)
            case .visitorOnHoldUpdated(let isOnHold):
                self?.delegate?(.visitorOnHoldUpdated(isOnHold: isOnHold))
            }
        }
        return CallViewController(
            viewModel: viewModel,
            viewFactory: viewFactory
        )
    }
}

extension CallCoordinator {
    struct Environment {
        var chatStorage: Glia.Environment.ChatStorage
        var fetchFile: CoreSdkClient.FetchFile
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var fromHistory: () -> Bool
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var submitSurveyAnswer: CoreSdkClient.SubmitSurveyAnswer
    }
}
