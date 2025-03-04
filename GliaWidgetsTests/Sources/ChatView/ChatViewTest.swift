import XCTest
@testable import GliaWidgets

final class ChatViewTest: XCTestCase {

    var view: ChatView!

    func test_contentForChatItemIsChoiceCardIfThereIsBrokenMetadata() throws {
        let env = EngagementView.Environment(
            data: .failing,
            uuid: { .mock },
            gcd: .failing,
            imageViewCache: .failing,
            timerProviding: .failing,
            uiApplication: .failing,
            uiScreen: .failing,
            combineScheduler: .mock
        )
        view = ChatView(
            with: .mock(),
            messageRenderer: .webRenderer,
            environment: env,
            props: .init(header: .mock())
        )
        let metadataDecodingContainer = try CoreSdkMessageMetadataContainer(
            jsonData: "{ }".data(using: .utf8)!
        ).container
        let message = ChatMessage.mock(
            sender: .operator,
            attachment: ChatAttachment.mock(
                type: .singleChoice,
                files: nil,
                imageUrl: nil,
                options: nil
            ),
            metadata: MessageMetadata(container: metadataDecodingContainer)
        )
        let item = try XCTUnwrap(ChatItem(
            with: message,
            isCustomCardSupported: true
        ))
        switch view.content(for: item) {
        case .choiceCard:
            break
        default:
            XCTFail("Content should be .choiceCard")
        }
    }

    func test_viewIsReleasedOnceModuleIsClosedWithResponseCardsInTranscript() throws {
        guard #available(iOS 17, *) else {
            throw XCTSkip("""
                This test does not pass on OS lower than iOS 17, but actual fix work well.
                So it was decided to leave it for local usage and for future,
                once target device version will be bumped.
            """)
        }
        var coordinatorEnv = EngagementCoordinator.Environment.failing
        coordinatorEnv.dismissManager.dismissViewControllerAnimateWithCompletion = { _, _, completion in
            completion?()
        }
        coordinatorEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        coordinatorEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        coordinatorEnv.createFileUploadListModel = { _ in .mock() }
        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        coordinatorEnv.uiApplication.windows = { [window] }
        coordinatorEnv.loadChatMessagesFromHistory = { true }
        coordinatorEnv.getCurrentEngagement = { nil }
        coordinatorEnv.isAuthenticated = { true }
        coordinatorEnv.maximumUploads = { 1 }
        coordinatorEnv.getNonTransferredSecureConversationEngagement = { nil }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        coordinatorEnv.log = logger
        coordinatorEnv.createEntryWidget = { _ in .mock() }
        let options: [ChatChoiceCardOption] = [try .mock()]
        coordinatorEnv.fetchChatHistory = {
            $0(
                .success(
                    [
                        .mock(attachment: .mock(
                            type: .singleChoice,
                            files: [],
                            imageUrl: nil,
                            options: options
                        ))
                    ]
                )
            )
        }
        let coordinator = EngagementCoordinator.mock(
            engagementLaunching: .direct(kind: .chat),
            environment: coordinatorEnv
        )
        coordinator.start()

        weak var controller = try XCTUnwrap(coordinator.navigationPresenter.viewControllers.last as? ChatViewController)
        weak var viewModel = try XCTUnwrap(controller?.viewModel.engagementModel as? ChatViewModel)
        viewModel?.event(.closeTapped)
        
        XCTAssertNil(controller)
        XCTAssertNil(viewModel)
    }

    func test_isTopBannerHiddenWhenIsTopBannerAllowedIsFalse() throws {
        throw XCTSkip("""
                This test should be un-skipped when injected combine scheduler will be added in EntryWidget in MOB-4077.
            """)
        let env = EngagementView.Environment(
            data: .failing,
            uuid: { .mock },
            gcd: .failing,
            imageViewCache: .failing,
            timerProviding: .failing,
            uiApplication: .failing,
            uiScreen: .failing,
            combineScheduler: .mock
        )
        view = ChatView(
            with: .mock(),
            messageRenderer: .webRenderer,
            environment: env,
            props: .init(header: .mock())
        )

        var entryWidgetEnv = EntryWidget.Environment.mock()
        let queueId = "queueId"
        let mockQueue = CoreSdkClient.Queue.mock(id: queueId, media: [.text, .audio, .messaging])
        let queuesMonitor = QueuesMonitor.mock(
            listQueues: {
                $0([mockQueue], nil)
            },
            subscribeForQueuesUpdates: { _, completion in
                completion(.success(mockQueue))
                return UUID.mock.uuidString
            },
            unsubscribeFromUpdates: nil
        )
        queuesMonitor.fetchAndMonitorQueues(queuesIds: [queueId])
        entryWidgetEnv.queuesMonitor = queuesMonitor
        let entryWidget = EntryWidget(
            queueIds: [queueId],
            configuration: .default,
            environment: entryWidgetEnv
        )
        view.entryWidget = entryWidget

        view.setIsTopBannerAllowed(true)
        XCTAssertFalse(view.isTopBannerHidden)

        view.setIsTopBannerAllowed(false)
        XCTAssertTrue(view.isTopBannerHidden)
    }
}
