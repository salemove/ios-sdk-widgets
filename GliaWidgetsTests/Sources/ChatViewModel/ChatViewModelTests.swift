@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK
import Combine
import XCTest

class ChatViewModelTests: XCTestCase {

    var viewModel: ChatViewModel!

    func test__choiceOptionSelected() throws {

        enum Call { case sendSelectedOptionValue }
        var calls = [Call]()

        var fileManager = FoundationBased.FileManager.failing
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [URL(fileURLWithPath: "/i/m/mocked/url")] }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let choiceCardMock = try ChatChoiceCardOption.mock()
        viewModel = .init(
            interactor: .mock(),
            call: .init(with: nil),
            unreadMessages: .init(with: 0),
            showsCallBubble: true,
            isCustomCardSupported: false,
            isWindowVisible: .init(with: true),
            startAction: .none,
            deliveredStatusText: "Delivered",
            failedToDeliverStatusText: "Failed",
            chatType: .nonAuthenticated,
            replaceExistingEnqueueing: false,
            environment: .init(
                secureConversations: .failing,
                fetchFile: { _, _, _ in },
                uploadFileToEngagement: { _, _, _ in },
                fileManager: fileManager,
                data: .failing,
                date: { Date.mock },
                gcd: .failing,
                uiScreen: .failing,
                createThumbnailGenerator: { .failing },
                createFileDownload: { _, _, _ in
                    .mock(
                        file: .mock(),
                        storage: FileSystemStorage.failing,
                        environment: .failing
                    )
                },
                loadChatMessagesFromHistory: { true },
                fetchSiteConfigurations: { _ in },
                getCurrentEngagement: { nil },
                getNonTransferredSecureConversationEngagement: { nil },
                timerProviding: .mock,
                uuid: { .mock },
                uiApplication: .mock,
                fetchChatHistory: { _ in },
                fileUploadListStyle: .mock,
                createFileUploadListModel: { _ in
                    .mock()
                },
                createSendMessagePayload: { text, attachment in
                    if text == choiceCardMock.text,
                       attachment?.type == .singleChoiceResponse {
                        calls.append(.sendSelectedOptionValue)
                    }
                    return .mock()
                },
                proximityManager: .mock,
                log: .mock,
                cameraDeviceManager: { .mock },
                flipCameraButtonStyle: .nop,
                alertManager: .mock(),
                isAuthenticated: { false },
                notificationCenter: .mock,
                markUnreadMessagesDelay: { .mock },
                combineScheduler: .mock,
                createEntryWidget: { _ in .mock() },
                topBannerItemsStyle: .mock(),
                switchToEngagement: .nop,
                shouldShowLeaveSecureConversationDialog: { _ in false }
            ),
            maximumUploads: { 2 }
        )

        viewModel.sendChoiceCardResponse(choiceCardMock, to: "mocked-message-id")

        XCTAssertEqual(calls, [.sendSelectedOptionValue])
    }

    func test_secureTranscriptChatTypeCases() throws {
        let viewModel: ChatViewModel = .mock(chatType: .secureTranscript(upgradedFromChat: false))
        viewModel.update(for: .enqueueing(.chat))
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 0)
        viewModel.handle(pendingMessage: .mock())
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
    }

    func test_authenticatedChatTypeCases() throws {
        let viewModel: ChatViewModel = .mock(chatType: .authenticated)
        viewModel.update(for: .enqueueing(.chat))
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
        viewModel.handle(pendingMessage: .mock())
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
    }

    func test_nonAuthenticatedChatTypeCases() throws {
        let viewModel: ChatViewModel = .mock(chatType: .nonAuthenticated)
        viewModel.update(for: .enqueueing(.chat))
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
        viewModel.handle(pendingMessage: .mock())
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
    }

    func test_chatTypeResponse() throws {
        var chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: false,
            startWithSecureTranscriptFlow: true,
            isAuthenticated: true
        )
        XCTAssertEqual(chatType, .secureTranscript(upgradedFromChat: false))
        chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: true,
            startWithSecureTranscriptFlow: false,
            isAuthenticated: false
        )
        XCTAssertEqual(chatType, .secureTranscript(upgradedFromChat: true))
        chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: false,
            startWithSecureTranscriptFlow: false,
            isAuthenticated: true
        )
        XCTAssertEqual(chatType, .authenticated)
        chatType = ChatCoordinator.chatType(
            isTransferredToSecureConversations: false,
            startWithSecureTranscriptFlow: false,
            isAuthenticated: false
        )
        XCTAssertEqual(chatType, .nonAuthenticated)
    }

    func test_onInteractorStateEngagedClearsChatQueueSection() throws {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let interactor: Interactor = .mock()
        interactor.setCurrentEngagement(.mock())
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)
        let queueSectionIndex: Int = viewModel.queueOperatorSection.index
        let mockOperator: CoreSdkClient.Operator = .mock()

        XCTAssertEqual(0, viewModel.numberOfItems(in: queueSectionIndex))
        viewModel.update(for: .enqueueing(.chat))
        XCTAssertEqual(1, viewModel.numberOfItems(in: queueSectionIndex))
        viewModel.update(for: .engaged(mockOperator))
        XCTAssertEqual(0, viewModel.numberOfItems(in: queueSectionIndex))
    }

    func test_onEngagementTransferringAddsTransferringItemToTheEndOfChat() throws {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        viewModelEnv.log = logger
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let interactor: Interactor = .mock(environment: interactorEnv)
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)

        interactor.onEngagementTransferring()

        let lastSectionIndex = viewModel.numberOfSections - 1
        let lastSectionLastItemIndex = viewModel.numberOfItems(in: lastSectionIndex) - 1
        let lastItemKind = viewModel.item(for: lastSectionLastItemIndex, in: lastSectionIndex).kind

        XCTAssertEqual(lastItemKind, .transferring)
    }

    func test_onEngagementTransferRemovesTransferringItemFromChat() throws {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        
        let interactor: Interactor = .mock(environment: interactorEnv)
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)

        interactor.onEngagementTransferring()

        let lastSectionIndex = viewModel.numberOfSections - 1
        let lastSectionLastItemIndex = viewModel.numberOfItems(in: lastSectionIndex) - 1
        let lastItemKind = viewModel.item(for: lastSectionLastItemIndex, in: lastSectionIndex).kind

        XCTAssertEqual(lastItemKind, .transferring)

        let mockOperator: CoreSdkClient.Operator = .mock()
        interactor.onEngagementTransfer([mockOperator])

        XCTAssertFalse(viewModel.messagesSection.items.contains(where: { $0.kind == .transferring }))
    }

    func test_onEngagementTransferAddsOperatorConnectedChatItemToTheEndOfChat() throws {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.async = { $0() }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let interactor: Interactor = .mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock())
        
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)
        let mockOperator: CoreSdkClient.Operator = .mock()
        let mockItemKind: ChatItem.Kind = .operatorConnected(name: mockOperator.firstName, imageUrl: mockOperator.picture?.url)

        interactor.onEngagementTransfer([mockOperator])

        let lastSectionIndex = viewModel.numberOfSections - 1
        let lastSectionLastItemIndex = viewModel.numberOfItems(in: lastSectionIndex) - 1
        let lastItemKind = viewModel.item(for: lastSectionLastItemIndex, in: lastSectionIndex).kind

        XCTAssertEqual(lastItemKind, mockItemKind)
    }

    func test__updateDoesNotCallSDKFetchSiteConfigurationsOnEnqueueingState() throws {
        // Given
        enum Calls { case fetchSiteConfigurations }
        var calls: [Calls] = []
        let interactorEnv = Interactor.Environment(coreSdk: .failing, queuesMonitor: .mock(), gcd: .mock, log: .mock)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fetchSiteConfigurations = { _ in
            calls.append(.fetchSiteConfigurations)
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        // When
        viewModel.update(for: .enqueueing(.chat))

        // Then
        XCTAssertEqual(calls, [])
    }

    func test__updateCallsSDKFetchSiteConfigurationsOnEngagedState() throws {
        // Given
        enum Calls { case fetchSiteConfigurations }
        var calls: [Calls] = []
        var interactorEnv = Interactor.Environment.init(coreSdk: .failing, queuesMonitor: .mock(), gcd: .mock, log: .mock)
        var interactorLog = CoreSdkClient.Logger.failing
        interactorLog.infoClosure = { _, _, _, _ in }
        interactorLog.prefixedClosure = { _ in interactorLog }
        interactorEnv.log = interactorLog
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock())
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.fetchSiteConfigurations = { _ in
            calls.append(.fetchSiteConfigurations)
        }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        // When
        viewModel.update(for: .engaged(nil))

        // Then
        XCTAssertEqual(calls, [.fetchSiteConfigurations])
	}

    func test_handleUrlWithPhoneOpensURLWithUIApplication() throws {
        enum Call: Equatable { case openUrl(URL) }

        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.uiApplication.canOpenURL = { _ in true }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.uiApplication.open = {
            calls.append(.openUrl($0))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(interactor: .mock(), environment: viewModelEnv)

        let telUrl = try XCTUnwrap(URL(string: "tel:12345678"))
        viewModel.linkTapped(telUrl)

        XCTAssertEqual(calls, [.openUrl(telUrl)])
    }

    func test_handleUrlWithEmailOpensURLWithUIApplication() throws {
        enum Call: Equatable { case openUrl(URL) }

        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.uiApplication.canOpenURL = { _ in true }
        viewModelEnv.uiApplication.open = {
            calls.append(.openUrl($0))
        }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(interactor: .mock(), environment: viewModelEnv)

        let mailUrl = try XCTUnwrap(URL(string: "mailto:mock@mock.mock"))
        viewModel.linkTapped(mailUrl)

        XCTAssertEqual(calls, [.openUrl(mailUrl)])
    }

    func test_handleUrlWithLinkOpensCalsLinkTapped() throws {
        enum Call: Equatable { case canOpen(URL), open(URL) }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return true
        }
        viewModelEnv.uiApplication.open = { url in
            calls.append(.open(url))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(
            interactor: .mock(),
            environment: viewModelEnv
        )

        let linkUrl = try XCTUnwrap(URL(string: "https://mock.mock"))
        viewModel.linkTapped(linkUrl)

        XCTAssertEqual(calls, [.canOpen(linkUrl), .open(linkUrl)])
    }
    
    func test_handleUrlThatCanNotBeOpenedShouldLog() throws {
        enum Call: Equatable { case canOpen(URL), log }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return false
        }
        viewModelEnv.uiApplication.open = { _ in
        }
        viewModelEnv.log.prefixedClosure = { prefix in
            calls.append(.log)
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(
            interactor: .mock(),
            environment: viewModelEnv
        )

        let linkUrl = try XCTUnwrap(URL(string: "https://mock.mock"))
        viewModel.linkTapped(linkUrl)

        XCTAssertEqual(calls, [.canOpen(linkUrl), .log])
    }

    func test_handleUrlWithRandomScheme() throws {
        enum Call: Equatable { case canOpen(URL), open(URL) }

        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.uiApplication.canOpenURL = { url in
            calls.append(.canOpen(url))
            return true
        }
        viewModelEnv.uiApplication.open = {
            calls.append(.open($0))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(interactor: .mock(), environment: viewModelEnv)

        let mockUrl = try XCTUnwrap(URL(string: "mock://mock"))
        viewModel.linkTapped(mockUrl)

        XCTAssertEqual(calls, [.canOpen(mockUrl), .open(mockUrl)])
    }

    func test_deliveryStatusText() {
        let deliveredStatusText = "This message has been delivered"
        let messageContent = "Message"

        var environment: Interactor.Environment = .mock
        environment.coreSdk.sendMessageWithMessagePayload = { _, completion in
            let coreSdkMessage = Message(
                id: UUID().uuidString,
                content: messageContent,
                sender: MessageSender.mock,
                metadata: nil
            )
            completion(.success(coreSdkMessage))
        }

        // `sendMessageWithAttachment` goes through this method first, so if
        // we use the mocked one, which doesn't execute the completion,
        // `sendMessageWithAttachment` will not be executed.
        environment.coreSdk.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }

        let viewModel: ChatViewModel = .mock(
            interactor: .mock(environment: environment),
            deliveredStatusText: deliveredStatusText
        )

        viewModel.action = { action in
            switch action {
            // `refreshRows` is the action called when a message is sent
            // and delivered.
            case .refreshRows(let row, let section, _):
                // As there is only one message refreshed because we
                // just send one message, the first row is retrieved.
                let item = viewModel.item(for: row.first!, in: section)
                if case .visitorMessage(_, let status) = item.kind {
                    XCTAssertEqual(status, deliveredStatusText)
                } else {
                    XCTFail("Refreshed message is of incorrect type.")
                }
            default: break
            }
        }

        viewModel.interactor.state = .engaged(nil)

        // Simulate typing and message and pressing the send button
        viewModel.event(.messageTextChanged(messageContent))
        viewModel.event(.sendTapped)
    }

    func testMigrateSetsExpectedFieldsFromTranscriptModelAndCallsActions() throws {
        typealias TranscriptModel = SecureConversations.TranscriptModel
        typealias FileUploadListViewModel = SecureConversations.FileUploadListViewModel
        var fileManager = FoundationBased.FileManager.failing
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        var transcriptModelEnv = TranscriptModel.Environment.failing
        transcriptModelEnv.fileManager = fileManager
        transcriptModelEnv.maximumUploads = { 2 }
        transcriptModelEnv.createEntryWidget = { _ in .mock() }
        var uploaderEnv = FileUploader.Environment.failing
        uploaderEnv.fileManager = fileManager
        let transcriptFileUploadListModelEnv = FileUploadListViewModel.Environment.failing(
            uploader: .mock(environment: uploaderEnv)
        )
        let fileUpload = FileUpload.mock()
        fileUpload.environment.uploadFile = .toSecureMessaging({ _, _, _ in .mock })
        transcriptFileUploadListModelEnv.uploader.uploads = [fileUpload]

        let transcriptFileUploadListModel = FileUploadListViewModel(environment: transcriptFileUploadListModelEnv)
        transcriptModelEnv.createFileUploadListModel = { _ in transcriptFileUploadListModel }
        transcriptModelEnv.getQueues = { callback in callback(.success([])) }
        transcriptModelEnv.maximumUploads = { 2 }
        var logger = CoreSdkClient.Logger.failing
        logger.prefixedClosure = { _ in logger }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { _, _, _, _ in }
        transcriptModelEnv.log = logger

        let availabilityEnv = SecureConversations.Availability.Environment(
            getQueues: transcriptModelEnv.getQueues,
            isAuthenticated: { true },
            log: logger,
            queuesMonitor: .mock(),
            getCurrentEngagement: { .mock() }
        )
        let transcriptModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: transcriptModelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            failedToDeliverStatusText: "",
            unreadMessages: ObservableValue<Int>.init(with: .zero),
            interactor: .failing
        )

        transcriptModel.sections[transcriptModel.pendingSection.index].append(.init(kind: .unreadMessageDivider))

        var chatViewModelEnv = ChatViewModel.Environment.failing()
        chatViewModelEnv.fileManager = fileManager
        chatViewModelEnv.createFileUploadListModel = {
            .mock(environment: $0)
        }
        chatViewModelEnv.uiApplication.preferredContentSizeCategory = { .unspecified }
        chatViewModelEnv.createEntryWidget = { _ in .mock() }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        var calls: [Call] = []
        chatViewModel.action = { action in
            switch action {
            case let .scrollToBottom(animated):
                calls.append(.scrollToBottom(animated: animated))
            default:
                break
            }
        }
        transcriptModel.event(.messageTextChanged("mock"))
        chatViewModel.migrate(from: transcriptModel)

        let itemKind = chatViewModel.pendingSection.items.first(
            where: {
                switch $0.kind {
                case .unreadMessageDivider:
                    return true
                default:
                    return false
                }
            }
        )
        // Make sure that pending section is shared with chat model.
        XCTAssertTrue(transcriptModel.pendingSection === chatViewModel.pendingSection)
        XCTAssertNotNil(itemKind)
        // Ensure that uploads migrated as well.
        XCTAssertTrue(try XCTUnwrap(chatViewModel.fileUploadListModel.environment.uploader.uploads.first) === fileUpload)
        XCTAssertNotNil(chatViewModel.fileUploadListModel.environment.uploader.uploads.first(where: {
            switch $0.environment.uploadFile {
            case .toEngagement:
                return true
            case .toSecureMessaging:
                return false
            }
        }))
        XCTAssertTrue(chatViewModel.isViewActive.value)
        XCTAssertEqual(chatViewModel.isViewLoaded, transcriptModel.isViewLoaded)
        XCTAssertEqual(chatViewModel.messageText, transcriptModel.messageText)
        enum Call: Equatable {
            case scrollToBottom(animated: Bool)
        }
        XCTAssertEqual(calls, [.scrollToBottom(animated: true)])
    }

    func test_messagesIdsFromHistoryAreStoredInHistoryMessageIds() {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        let expectedMessageId = "expected_message_id".uppercased()
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([.mock(id: expectedMessageId)]))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.start()
        XCTAssertEqual(viewModel.historyMessageIds, [expectedMessageId])
    }

    func test_messageReceivedFromSocketIsRemovedWhenSameMessageArrivesFromHistory() {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        let expectedMessageId = "expected_message_id".uppercased()
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([.mock(id: expectedMessageId)]))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)

        viewModel.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))
        XCTAssertEqual(viewModel.receivedMessageIds, [expectedMessageId])

        viewModel.start()
        XCTAssertEqual(viewModel.historyMessageIds, [expectedMessageId])
        XCTAssertEqual(viewModel.receivedMessageIds, [])
        XCTAssertTrue(viewModel.messagesSection.items.isEmpty)
    }

    func test_messageReceivedFromSocketIsDiscarded() {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([.mock(id: expectedMessageId)]))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.start()
        var actions: [ChatViewModel.Action] = []
        viewModel.action = {
            actions.append($0)
        }
        viewModel.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))
        XCTAssertTrue(actions.isEmpty)
    }

    func test_messageReceivedFromSocketIsNotDiscarded() {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.fetchChatHistory = { _ in }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let messageId = "message_id"
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        var actions: [ChatViewModel.Action] = []
        viewModel.action = {
            actions.append($0)
        }
        viewModel.interactorEvent(.receivedMessage(.mock(id: messageId)))
        enum Call {
            case quickReplyPropsUpdatedHidden
        }
        var calls: [Call] = []
        switch actions[0] {
        case .quickReplyPropsUpdated(.hidden):
            calls.append(.quickReplyPropsUpdatedHidden)
        default:
            break
        }
        XCTAssertEqual(viewModel.receivedMessageIds, [messageId.uppercased()])
    }

    func test_messageReceivedFromSocketWithSameIdIsDiscarded() {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()

        viewModel.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))
        viewModel.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))
        XCTAssertEqual(viewModel.messagesSection.items.count, 1)
        XCTAssertEqual(viewModel.receivedMessageIds, [expectedMessageId.uppercased()])
    }

    func test_messageReceivedFirstFromRestDiscardsSameOneFromSocket() throws {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        var log = viewModelEnv.log
        log.prefixedClosure = { _ in log }
        log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log = log
        let messageIdSuffix = "1D_123"
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: messageIdSuffix, content: $0, attachment: $1)
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let interactor = Interactor.failing
        interactor.setCurrentEngagement(.mock())
        var interactorLog = CoreSdkClient.Logger.failing
        interactorLog.infoClosure = { _, _, _, _ in }
        interactorLog.prefixedClosure = { _ in interactorLog }
        interactor.environment.log = interactorLog
        interactor.environment.gcd.mainQueue.async = { $0() }
        interactor.environment.coreSdk.configureWithInteractor = { _ in }
        interactor.environment.coreSdk.configureWithConfiguration = { _, callback in callback(.success(())) }
        interactor.environment.coreSdk.sendMessagePreview = { _, _ in }
        interactor.environment.coreSdk.sendMessageWithMessagePayload = { _, completion in
            completion(.success(.mock(id: expectedMessageId)))
        }
        interactor.environment.coreSdk.queueForEngagement = { _, _, completion in
            completion(.success(.mock))
        }

        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        interactor.state = .engaged(.mock())
        viewModel.invokeSetTextAndSendMessage(text: "Mock send message.")

        viewModel.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))

        let lastMessage = viewModel.messagesSection.items.last?.kind
        var receivedMessage: ChatMessage?
        switch try XCTUnwrap(lastMessage) {
        case let .visitorMessage(message, _):
            receivedMessage = message
        default:
            XCTFail("Expected visitor message. Got \(String(describing: lastMessage)) instead.")
        }

        XCTAssertEqual(viewModel.messagesSection.items.count, 2)
        XCTAssertEqual(viewModel.receivedMessageIds, [expectedMessageId.uppercased()])
        XCTAssertEqual(try XCTUnwrap(receivedMessage).id, expectedMessageId)
    }

    func test_messageReceivedFirstFromSocketDiscardsSameOneFromRest() throws {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        var log = viewModelEnv.log
        log.prefixedClosure = { _ in log }
        log.infoClosure = { _, _, _, _ in }
        viewModelEnv.log = log
        let messageIdSuffix = "1D_123"
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: messageIdSuffix, content: $0, attachment: $1)
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let interactor = Interactor.failing
        interactor.setCurrentEngagement(.mock())
        var interactorLog = interactor.environment.log
        interactorLog.prefixedClosure = { _ in log }
        interactorLog.infoClosure = { _, _, _, _ in }
        interactor.environment.log = interactorLog
        interactor.environment.gcd.mainQueue.async = { $0() }
        interactor.environment.coreSdk.configureWithInteractor = { _ in }
        interactor.environment.coreSdk.configureWithConfiguration = { _, callback in callback(.success(())) }
        interactor.environment.coreSdk.sendMessagePreview = { _, _ in }
        interactor.environment.coreSdk.sendMessageWithMessagePayload = { [weak viewModel] _, completion in
            // Deliver message via socket before REST API response.
            viewModel?.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))
            completion(.success(.mock(id: expectedMessageId)))
        }
        interactor.environment.coreSdk.queueForEngagement = { _, _, completion in
            completion(.success(.mock))
        }

        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        viewModel.interactor.state = .enqueueing(.chat)
        interactor.state = .engaged(.mock())
        viewModel.invokeSetTextAndSendMessage(text: "Mock send message.")
        viewModel.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))

        let lastMessage = viewModel.messagesSection.items.last?.kind
        var receivedMessage: ChatMessage?
        switch try XCTUnwrap(lastMessage) {
        case let .visitorMessage(message, _):
            receivedMessage = message
        default:
            XCTFail("Expected visitor message. Got \(String(describing: lastMessage)) instead.")
        }

        XCTAssertEqual(viewModel.messagesSection.items.count, 2)
        XCTAssertEqual(viewModel.receivedMessageIds, [expectedMessageId.uppercased()])
        XCTAssertEqual(try XCTUnwrap(receivedMessage).id, expectedMessageId)
    }

    func test_messageContainedInPendingSectionDiscardsOneDeliveredViaSocket() throws {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        let messageIdSuffix = "1D_123"

        let outgoingMessage = OutgoingMessage(payload: .mock(messageIdSuffix: messageIdSuffix))
        viewModel.pendingSection.append(
            .init(kind: .outgoingMessage(outgoingMessage, error: nil))
        )

        viewModel.interactorEvent(.receivedMessage(.mock(id: outgoingMessage.payload.messageId.rawValue)))
        XCTAssertEqual(viewModel.messagesSection.items.count, 0)
        XCTAssertEqual(viewModel.receivedMessageIds, [])
    }

    func test_liveObservationAlertPresentationInitiatedWhenInteractorStateIsEnqueuing() throws {
        enum Call {
            case showLiveObservationAlert
        }
        var calls: [Call] = []
        let interactor: Interactor = .mock()
        let site: CoreSdkClient.Site = try .mock()
        var viewModelEnvironment: EngagementViewModel.Environment = .mock
        viewModelEnvironment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        let viewModel: ChatViewModel = .mock(
            interactor: interactor,
            environment: viewModelEnvironment
        )
        viewModel.engagementAction = { action in
            switch action {
            case .showLiveObservationConfirmation:
                calls.append(.showLiveObservationAlert)
            default:
                XCTFail()
            }
        }
        interactor.state = .enqueueing(.audioCall)
        XCTAssertEqual(calls, [.showLiveObservationAlert])
    }

    func test_liveObservationAllowTriggersEnqueue() throws {
        var interactorEnv: Interactor.Environment = .mock
        interactorEnv.coreSdk.queueForEngagement = { _, _, completion in
            completion(.success(.mock))
        }

        let interactor: Interactor = .mock(environment: interactorEnv)
        var alertConfig: GliaWidgets.LiveObservation.Confirmation?
        let site: CoreSdkClient.Site = try .mock()
        
        var viewModelEnvironment: EngagementViewModel.Environment = .mock
        viewModelEnvironment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        let viewModel: ChatViewModel = .mock(
            interactor: interactor,
            environment: viewModelEnvironment
        )

        viewModel.engagementAction = { action in
            switch action {
            case let .showLiveObservationConfirmation(link, accepted, declined):
                alertConfig = .init(
                    link: link,
                    accepted: accepted,
                    declined: declined
                )
            default:
                XCTFail()
            }
        }
        interactor.state = .enqueueing(.audioCall)
        alertConfig?.accepted()
        XCTAssertEqual(interactor.state, .enqueued(.mock, .audioCall))
    }

    func test_liveObservationDeclineTriggersNone() throws {
        enum Call {
            case queueForEngagement
        }
        var calls: [Call] = []
        var interactorEnv: Interactor.Environment = .mock
        interactorEnv.coreSdk.queueForEngagement = { _, _, _ in
            calls.append(.queueForEngagement)
        }

        let interactor: Interactor = .mock(environment: interactorEnv)
        var alertConfig: GliaWidgets.LiveObservation.Confirmation?
        let site: CoreSdkClient.Site = try .mock()

        var viewModelEnvironment: EngagementViewModel.Environment = .mock
        viewModelEnvironment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        let viewModel: ChatViewModel = .mock(
            interactor: interactor,
            environment: viewModelEnvironment
        )
        viewModel.engagementAction = { action in
            switch action {
            case let .showLiveObservationConfirmation(link, accepted, declined):
                alertConfig = .init(
                    link: link,
                    accepted: accepted,
                    declined: declined
                )
            default:
                XCTFail()
            }
        }
        interactor.state = .enqueueing(.audioCall)
        alertConfig?.declined()
        XCTAssertEqual(interactor.state, .ended(.byVisitor))
        XCTAssertTrue(calls.isEmpty)
    }

    func test_alertInputTypeWhenEngagementIsEndedByOperator() {
        var alertInputType: AlertInputType?

        let delegate: (EngagementViewModel.Action) -> Void = { action in
            switch action {
            case let .showAlert(type):
                alertInputType = type
            default: break
            }
        }

        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd = .mock
        interactorEnv.coreSdk.getCurrentEngagement = {
            .mock(fetchSurvey: { _, completion in
                completion(.success(nil))
            })
        }

        let interactor = Interactor.mock(environment: interactorEnv)

        viewModel = .mock(interactor: interactor)
        viewModel.engagementAction = delegate

        interactor.end(with: .operatorHungUp)

        let isValidInput: Bool
        if case .operatorEndedEngagement = alertInputType {
            isValidInput = true
        } else {
            isValidInput = false
        }
        XCTAssertTrue(isValidInput)
    }

    func test_quickReplyWillBeHiddenAfterMessageIsSent() throws {
        enum Calls { case quickReplyHidden }
        var calls: [Calls] = []
        let interactorEnv = Interactor.Environment(coreSdk: .failing, queuesMonitor: .failing, gcd: .mock, log: .mock)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        viewModel.action = { action in
            switch action {
            case let .quickReplyPropsUpdated(state):
                switch state {
                case .shown:
                    break
                case .hidden:
                    calls.append(.quickReplyHidden)
                }
            default:
                break
            }
        }
        viewModel.event(.sendTapped)
        XCTAssertEqual(calls, [.quickReplyHidden])
    }

    func test_pendingMessageGetsRemovedFromListWhenMessageIsSentSuccesfully() {
        var interactorEnv = Interactor.Environment(coreSdk: .failing, queuesMonitor: .failing, gcd: .mock, log: .mock)
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { payload, callback in
            callback(.success(.mock(id: payload.messageId.rawValue)))
        }
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock())
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.log = .mock
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        let pendingMessages: [OutgoingMessage] = [
            .mock(payload: .mock(messageIdSuffix: "0")),
            .mock(payload: .mock(messageIdSuffix: "1"))
        ]
        viewModel.setPendingMessagesForTesting(pendingMessages)
        XCTAssertEqual(pendingMessages, viewModel.getPendingMessageForTesting())
        viewModel.update(for: .engaged(.mock()))
        XCTAssertTrue(viewModel.getPendingMessageForTesting().isEmpty)
    }

    func test_messageAttachmentIsKeptAfterFailureSending() throws {
        var interactorEnv = Interactor.Environment.mock
        interactorEnv.coreSdk.sendMessageWithMessagePayload = { _, callback in
            callback(.failure(.mock()))
        }
        interactorEnv.coreSdk.sendMessagePreview = { _, _ in }
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .engaged(nil)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }

        let upload = FileUpload.mock()
        upload.state.value = .uploaded(file: try .mock())
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = [upload]
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createSendMessagePayload = { .mock(content: $0, attachment: $1) }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        let messageContent = "Mock"
        viewModel.invokeSetTextAndSendMessage(text: messageContent)

        switch viewModel.messagesSection.items.last?.kind {
        case let .outgoingMessage(message, _):
            XCTAssertNotNil(message.payload.attachment)
            XCTAssertEqual(message.payload.content, messageContent)
        default:
            XCTFail("message kind should be `visitorMessage`")
        }
    }

    func test_engagementEndedByOperatorCallsEngagementAndDelegateActions() {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue = .mock
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .ended(.byOperator)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        enum Call {
            case engagementActionShowAlertWithOperatorEndedEngagement
            case engagementDelegateFinished
        }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            switch action {
            case .showAlert(.operatorEndedEngagement):
                calls.append(.engagementActionShowAlertWithOperatorEndedEngagement)
            default:
                break
            }
        }
        viewModel.engagementDelegate = { action in
            switch action {
            case .finished:
                calls.append(.engagementDelegateFinished)
            default:
                break
            }
        }

        viewModel.interactorEvent(.stateChanged(.ended(.byOperator)))
        XCTAssertEqual(calls, [.engagementActionShowAlertWithOperatorEndedEngagement])
        interactor.setEndedEngagement(.mock(actionOnEnd: .showSurvey))
        viewModel.interactorEvent(.stateChanged(.ended(.byOperator)))
        XCTAssertEqual(
            calls, [
                .engagementActionShowAlertWithOperatorEndedEngagement,
                .engagementDelegateFinished
            ]
        )
    }
    
    func test_engagementEndedByOperatorWithUnknownOnEndActionLogsWarning() {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue = .mock
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.state = .ended(.byOperator)
        var warnings: [String] = []
        let mockUnknownAction = "Unknown reason"

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.log = .mock
        viewModelEnv.log.warningClosure = { message, _, _, _ in
            warnings.append("\(message)")
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        enum Call {
            case engagementActionShowAlertWithOperatorEndedEngagement
        }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            switch action {
            case .showAlert(.operatorEndedEngagement):
                calls.append(.engagementActionShowAlertWithOperatorEndedEngagement)
            default:
                break
            }
        }

        interactor.setEndedEngagement(.mock(actionOnEnd: .unknown(mockUnknownAction)))
        viewModel.interactorEvent(.stateChanged(.ended(.byOperator)))
        XCTAssertEqual(calls, [.engagementActionShowAlertWithOperatorEndedEngagement])
        XCTAssertEqual(warnings, ["Engagement ended with unknown case '\(mockUnknownAction)'."])
    }

    func test_closeActionDoesNotShowConfirmationIfThereIsTransferredSC() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue = .mock
        interactorEnv.coreSdk.endEngagement = { _ in
            XCTFail("End engagement should not be called")
        }
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))
        interactor.state = .engaged(nil)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        enum Call {
            case engagementDelegateFinished
        }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            switch action {
            case .showAlert(.endEngagement(_)):
                XCTFail("End engagement dialog should not be shown")
            default:
                break
            }
        }
        viewModel.engagementDelegate = { action in
            switch action {
            case .finished:
                calls.append(.engagementDelegateFinished)
            default:
                break
            }
        }

        viewModel.event(.closeTapped)
        XCTAssertEqual(calls, [.engagementDelegateFinished])
    }

    func testShouldForceEnqueueingReturnsFalse() throws {
        let interactor = Interactor.mock(environment: .failing)
        interactor.setCurrentEngagement(.mock())
        interactor.state = .engaged(nil)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .authenticated,
            environment: viewModelEnv
        )

        XCTAssertFalse(viewModel.shouldForceEnqueueing)
    }

    func testShouldForceEnqueueingReturnsTrue() throws {
        let interactor = Interactor.mock(environment: .failing)
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))
        interactor.state = .engaged(nil)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .authenticated,
            environment: viewModelEnv
        )

        XCTAssertTrue(viewModel.shouldForceEnqueueing)
    }

    func testLoadHistoryStartsEnqueueingWhenReplaceExistingEnqueueingIsTrue() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue.async = { $0() }

        let interactor = Interactor.mock(environment: interactorEnv)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([.mock()]))
        }
        viewModelEnv.getNonTransferredSecureConversationEngagement = { nil }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .authenticated,
            replaceExistingEnqueueing: true,
            environment: viewModelEnv
        )

        viewModel.start()

        XCTAssertEqual(interactor.state, .enqueueing(.chat))
    }

    func testLoadHistoryStartsEnqueueingWhenTranscriptIsEmpty() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue.async = { $0() }

        let interactor = Interactor.mock(environment: interactorEnv)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.getNonTransferredSecureConversationEngagement = { nil }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .authenticated,
            environment: viewModelEnv
        )

        viewModel.start()

        XCTAssertEqual(interactor.state, .enqueueing(.chat))
    }

    func testLoadHistoryStartsEnqueueingWhenOngoingEngagementExists() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue.async = { $0() }

        let interactor = Interactor.mock(environment: interactorEnv)

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([.mock()]))
        }
        viewModelEnv.getNonTransferredSecureConversationEngagement = { .mock() }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .authenticated,
            environment: viewModelEnv
        )

        viewModel.start()

        XCTAssertEqual(interactor.state, .enqueueing(.chat))
    }

    func testTransferredScSwitchesChatTypeToAuthenticatedOnEngagedState() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue.async = { $0() }

        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.isAuthenticated = { true }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .secureTranscript(upgradedFromChat: true),
            environment: viewModelEnv
        )
        enum Call { case refreshAll, showEndButton }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            guard case .showEndButton = action else { return }
            calls.append(.showEndButton)
        }
        viewModel.action = { action in
            guard case .refreshAll = action else { return }
            calls.append(.refreshAll)
        }

        interactor.setCurrentEngagement(.mock())
        interactor.state = .engaged(nil)

        XCTAssertEqual(viewModel.chatType, .authenticated)
        XCTAssertEqual(calls, [.refreshAll, .refreshAll])
    }

    func testTransferredScShowsCloseButton() throws {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue.async = { $0() }
        interactorEnv.log.infoClosure = { _, _, _, _ in }
        interactorEnv.log.prefixedClosure = { _ in interactorEnv.log }

        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock())

        var viewModelEnv = ChatViewModel.Environment.failing()
        
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.log.prefixedClosure = { _ in viewModelEnv.log }
        viewModelEnv.log.infoClosure = { _, _, _, _ in }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.isAuthenticated = { true }
        viewModelEnv.createEntryWidget = { _ in .mock() }

        let viewModel = ChatViewModel.mock(
            interactor: interactor,
            chatType: .secureTranscript(upgradedFromChat: true),
            environment: viewModelEnv
        )
        enum Call { case refreshAll, showCloseButton }
        var calls: [Call] = []
        viewModel.engagementAction = { action in
            guard case .showCloseButton = action else { return }
            calls.append(.showCloseButton)
        }
        viewModel.action = { action in
            guard case .refreshAll = action else { return }
            calls.append(.refreshAll)
        }

        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))
        interactor.state = .engaged(nil)
        interactor.onLiveToSecureConversationsEngagementTransferring()

        XCTAssertEqual(viewModel.chatType, .secureTranscript(upgradedFromChat: true))
        XCTAssertEqual(calls, [.showCloseButton, .refreshAll])
    }

    func test_messageReceivedMarksAsReadIfOnEndIsRetain() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.markUnreadMessagesDelay = { .zero }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .active }
        viewModelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.interactorEvent(.receivedMessage(.mock(sender: .init(type: .operator))))

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }
    
    func test_messageReceivedDontMarksAsReadIfOnEndIsShowSurvey() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.markUnreadMessagesDelay = { .zero }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .showSurvey) }
        viewModelEnv.uiApplication.applicationState = { .active }
        viewModelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.interactorEvent(.receivedMessage(.mock(sender: .init(type: .operator))))

        XCTAssertTrue(calls.isEmpty)
    }
    
    func test_messageReceivedDontMarksAsReadIfSenderIsVisitor() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.markUnreadMessagesDelay = { .zero }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .active }
        viewModelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.isViewLoaded = true
        viewModel.start()
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.interactorEvent(.receivedMessage(.mock(sender: .init(type: .visitor))))

        XCTAssertTrue(calls.isEmpty)
    }
    
    func test_markMessagesAsRead() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.markUnreadMessagesDelay = { .zero }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .active }
        viewModelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.markMessagesAsRead()

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }
    
    func test_markMessagesAsReadNotTriggerBeforeDelay() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.combineScheduler = .live
        viewModelEnv.markUnreadMessagesDelay = { .milliseconds(100) }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .active }
        viewModelEnv.notificationCenter.publisherForNotification = { _ in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.markMessagesAsRead()

        XCTAssertTrue(calls.isEmpty)
    }
    
    func test_markMessagesAsReadNotTriggerIfApplicationInactive() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.markUnreadMessagesDelay = { .milliseconds(1) }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .inactive }
        viewModelEnv.notificationCenter.publisherForNotification = { type in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.markMessagesAsRead()

        XCTAssertTrue(calls.isEmpty)
    }
    
    func test_markMessagesAsReadNotTriggerIfApplicationGoBackground() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.combineScheduler = .live
        viewModelEnv.markUnreadMessagesDelay = { .milliseconds(1) }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .active }
        let notificationPublisher = PassthroughSubject<Notification, Never>()
        viewModelEnv.notificationCenter.publisherForNotification = { type in
            if type == UIApplication.didEnterBackgroundNotification {
                return notificationPublisher.eraseToAnyPublisher()
            }
            return Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.markMessagesAsRead()
        notificationPublisher.send(.init(name: UIApplication.didEnterBackgroundNotification))
        XCTAssertTrue(calls.isEmpty)
    }
    
    func test_markMessagesAsReadNotTriggerIfApplicationGoForeground() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.combineScheduler = .mock
        viewModelEnv.markUnreadMessagesDelay = { .milliseconds(1) }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .inactive }
        let notificationPublisher = PassthroughSubject<Notification, Never>()
        viewModelEnv.notificationCenter.publisherForNotification = { type in
            if type == UIApplication.willEnterForegroundNotification {
                return notificationPublisher.eraseToAnyPublisher()
            }
            return Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.markMessagesAsRead()
        notificationPublisher.send(.init(name: UIApplication.willEnterForegroundNotification))

        XCTAssertEqual(calls, [.secureMarkMessagesAsRead])
    }
    
    func test_markMessagesAsReadNotTriggerIfViewDidDisappear() {
        enum Call: Equatable { case secureMarkMessagesAsRead }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.combineScheduler = .live
        viewModelEnv.markUnreadMessagesDelay = { .milliseconds(1) }
        viewModelEnv.getCurrentEngagement = { .mock(actionOnEnd: .retain) }
        viewModelEnv.uiApplication.applicationState = { .active }
        viewModelEnv.notificationCenter.publisherForNotification = { type in
            Empty<Notification, Never>().eraseToAnyPublisher()
        }
        viewModelEnv.secureConversations.markMessagesAsRead = { completion in
            calls.append(.secureMarkMessagesAsRead)
            completion(.success(()))
            return .mock
        }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.event(EngagementViewModel.Event.viewDidAppear)

        viewModel.markMessagesAsRead()
        viewModel.event(EngagementViewModel.Event.viewDidDisappear)

        XCTAssertTrue(calls.isEmpty)
    }

    func test_handlingEngagedStateIsSkippedIfThereIsTransferredSC() {
        var interactorEnv = Interactor.Environment.failing
        interactorEnv.gcd.mainQueue = .mock
        let interactor = Interactor.mock(environment: interactorEnv)
        interactor.setCurrentEngagement(.mock(status: .transferring, capabilities: .init(text: true)))

        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.log.prefixedClosure = { _ in return .mock }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        let fileUploadListViewModelEnv = SecureConversations.FileUploadListViewModel.Environment.mock
        fileUploadListViewModelEnv.uploader.uploads = []
        viewModelEnv.createFileUploadListModel = { _ in .mock(environment: fileUploadListViewModelEnv) }
        viewModelEnv.createEntryWidget = { _ in .mock() }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        enum Call {
            case refreshAll, appendRows, connected, showSnackBarView
        }
        var calls: [Call] = []
        viewModel.action = { action in
            switch action {
            case .appendRows:
                calls.append(.appendRows)
            case .connected:
                calls.append(.connected)
            case .refreshAll:
                calls.append(.refreshAll)
            case .showSnackBarView:
                calls.append(.showSnackBarView)
            default:
                break
            }
        }

        interactor.state = .engaged(nil)

        XCTAssertEqual(calls, [])
    }
}

extension ChatChoiceCardOption {
    static func mock() throws -> ChatChoiceCardOption {
        // GliaCoreSDK.SingleChoiceOption has no available constructors but supports Codable
        //  protocol, so I decided that this is the most convenient way to get the instance of.
        let json = """
        { "text": "choice card text", "value": "choice card value" }
        """.utf8
        let mockedOption = try JSONDecoder().decode(
            SingleChoiceOption.self,
            from: Data(json)
        )
        return .init(with: mockedOption)
    }
}
