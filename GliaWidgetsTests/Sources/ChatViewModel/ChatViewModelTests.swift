@testable import GliaWidgets
import GliaCoreSDK
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
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            call: .init(with: nil),
            unreadMessages: .init(with: 0),
            showsCallBubble: true,
            isCustomCardSupported: false,
            isWindowVisible: .init(with: true),
            startAction: .none,
            deliveredStatusText: "Delivered",
            chatType: .nonAuthenticated,
            environment: .init(
                fetchFile: { _, _, _ in },
                downloadSecureFile: { _, _, _ in .mock },
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
                }
            )
        )

        viewModel.sendChoiceCardResponse(choiceCardMock, to: "mocked-message-id")

        XCTAssertEqual(calls, [.sendSelectedOptionValue])
    }

    func test_secureTranscriptChatTypeCases() throws {
        let viewModel: ChatViewModel = .mock(chatType: .secureTranscript)
        viewModel.update(for: .enqueueing)
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 0)
        viewModel.handle(pendingMessage: .mock())
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
    }

    func test_authenticatedChatTypeCases() throws {
        let viewModel: ChatViewModel = .mock(chatType: .authenticated)
        viewModel.update(for: .enqueueing)
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
        viewModel.handle(pendingMessage: .mock())
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
    }

    func test_nonAuthenticatedChatTypeCases() throws {
        let viewModel: ChatViewModel = .mock(chatType: .nonAuthenticated)
        viewModel.update(for: .enqueueing)
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
        viewModel.handle(pendingMessage: .mock())
        XCTAssertEqual(viewModel.queueOperatorSection.itemCount, 1)
    }

    func test_chatTypeResponse() throws {
        var chatType = ChatCoordinator.chatType(
            startWithSecureTranscriptFlow: true,
            isAuthenticated: true
        )
        XCTAssertEqual(chatType, .secureTranscript)
        chatType = ChatCoordinator.chatType(
            startWithSecureTranscriptFlow: false,
            isAuthenticated: true
        )
        XCTAssertEqual(chatType, .authenticated)
        chatType = ChatCoordinator.chatType(
            startWithSecureTranscriptFlow: false,
            isAuthenticated: false
        )
        XCTAssertEqual(chatType, .nonAuthenticated)
    }

    func test__startCallsSDKConfigureWithInteractorAndСonfigureWithConfiguration() throws {
        var interactorEnv = Interactor.Environment.init(
            coreSdk: .failing,
            gcd: .mock
        )
        enum Calls {
            case configureWithConfiguration, configureWithInteractor
        }
        var calls: [Calls] = []
        interactorEnv.coreSdk.configureWithConfiguration = { _, _ in
            calls.append(.configureWithConfiguration)
        }
        interactorEnv.coreSdk.configureWithInteractor = { _ in
            calls.append(.configureWithInteractor)
        }
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing(fetchChatHistory: { $0(.success([])) })
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        viewModel.start()
        XCTAssertEqual(calls, [.configureWithInteractor, .configureWithConfiguration])
    }
    
    func test_onInteractorStateEngagedClearsChatQueueSection() throws {
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        let interactor: Interactor = .mock()
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)
        let queueSectionIndex: Int = viewModel.queueOperatorSection.index
        let mockOperator: CoreSdkClient.Operator = .mock()

        XCTAssertEqual(0, viewModel.numberOfItems(in: queueSectionIndex))
        viewModel.update(for: .enqueueing)
        XCTAssertEqual(1, viewModel.numberOfItems(in: queueSectionIndex))
        viewModel.update(for: .engaged(mockOperator))
        XCTAssertEqual(0, viewModel.numberOfItems(in: queueSectionIndex))
    }
    
    func test_onEngagementTransferringAddsTransferringItemToTheEndOfChat() throws {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        
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
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }

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
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }

        let interactor: Interactor = .mock(environment: interactorEnv)
        let viewModel: ChatViewModel = .mock(interactor: interactor, environment: viewModelEnv)
        let mockOperator: CoreSdkClient.Operator = .mock()
        let mockItemKind: ChatItem.Kind = .operatorConnected(name: mockOperator.firstName, imageUrl: mockOperator.picture?.url)

        interactor.onEngagementTransfer([mockOperator])

        let lastSectionIndex = viewModel.numberOfSections - 1
        let lastSectionLastItemIndex = viewModel.numberOfItems(in: lastSectionIndex) - 1
        let lastItemKind = viewModel.item(for: lastSectionLastItemIndex, in: lastSectionIndex).kind

        XCTAssertEqual(lastItemKind, mockItemKind)
    }

    func test_screenSharingTerminationUponEngagmentTransferring() {
        let viewModel: ChatViewModel = .mock(screenShareHandler: .create())
        let state: CoreSdkClient.VisitorScreenSharingState = .init(status: .sharing, localScreen: nil)
        viewModel.screenShareHandler.updateState(state)

        XCTAssertEqual(viewModel.screenShareHandler.status().value, .started)

        viewModel.interactor.onEngagementTransferring()

        XCTAssertEqual(viewModel.screenShareHandler.status().value, .stopped)
    }

    func test__updateDoesNotCallSDKFetchSiteConfigurationsOnEnqueueingState() throws {
        // Given
        enum Calls { case fetchSiteConfigurations }
        var calls: [Calls] = []
        let interactorEnv = Interactor.Environment(coreSdk: .failing, gcd: .mock)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.fetchSiteConfigurations = { _ in
            calls.append(.fetchSiteConfigurations)
        }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        // When
        viewModel.update(for: .enqueueing)

        // Then
        XCTAssertEqual(calls, [])
    }

    func test__updateCallsSDKFetchSiteConfigurationsOnEngagedState() throws {
        // Given
        enum Calls { case fetchSiteConfigurations }
        var calls: [Calls] = []
        let interactorEnv = Interactor.Environment.init(coreSdk: .failing, gcd: .mock)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.fetchSiteConfigurations = { _ in
            calls.append(.fetchSiteConfigurations)
        }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
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
        let viewModel: ChatViewModel = .mock(interactor: .mock(), environment: viewModelEnv)

        let telUrl = URL(string: "tel:12345678")!
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
        let viewModel: ChatViewModel = .mock(interactor: .mock(), environment: viewModelEnv)

        let mailUrl = URL(string: "mailto:mock@mock.mock")!
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
        let viewModel: ChatViewModel = .mock(
            interactor: .mock(),
            environment: viewModelEnv
        )

        let linkUrl = URL(string: "https://mock.mock")!
        viewModel.linkTapped(linkUrl)

        XCTAssertEqual(calls, [.canOpen(linkUrl), .open(linkUrl)])
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
            completion?()
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
        fileManager.createDirectoryAtUrlWithIntermediateDirectories =  { _, _, _ in }

        var transcriptModelEnv = TranscriptModel.Environment.failing
        transcriptModelEnv.fileManager = fileManager
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
        transcriptModelEnv.listQueues = { callback in callback([], nil) }
        let availabilityEnv = SecureConversations.Availability.Environment(
            listQueues: transcriptModelEnv.listQueues,
            queueIds: transcriptModelEnv.queueIds,
            isAuthenticated: { true }
        )
        let transcriptModel = TranscriptModel(
            isCustomCardSupported: false,
            environment: transcriptModelEnv,
            availability: .init(
                environment: availabilityEnv
            ),
            deliveredStatusText: "",
            interactor: .failing,
            alertConfiguration: .mock()
        )

        transcriptModel.sections[transcriptModel.pendingSection.index].append(.init(kind: .unreadMessageDivider))

        var chatViewModelEnv = ChatViewModel.Environment.failing()
        chatViewModelEnv.fileManager = fileManager
        chatViewModelEnv.createFileUploadListModel = {
            .mock(environment: $0)
        }
        chatViewModelEnv.uiApplication.preferredContentSizeCategory = { .unspecified }
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
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([.mock(id: expectedMessageId)]))
        }
        let viewModel: ChatViewModel = .mock(environment: viewModelEnv)
        viewModel.start()
        XCTAssertEqual(viewModel.historyMessageIds, [expectedMessageId])
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
        let messageIdSuffix = "1D_123"
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: messageIdSuffix, content: $0, attachment: $1)
        }

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.asyncIfNeeded = { $0() }
        interactor.environment.coreSdk.configureWithInteractor = { _ in }
        interactor.environment.coreSdk.configureWithConfiguration = { _, callback in callback?() }
        interactor.environment.coreSdk.sendMessagePreview = { _, _ in }
        interactor.environment.coreSdk.sendMessageWithMessagePayload = { _, completion in
            completion(.success(.mock(id: expectedMessageId)))
        }
        interactor.environment.coreSdk.queueForEngagement = { _, _, _, _, _, completion in
            completion(.mock, nil)
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
        let messageIdSuffix = "1D_123"
        let expectedMessageId = "expected_message_id"
        viewModelEnv.fetchChatHistory = { callback in
            callback(.success([]))
        }
        viewModelEnv.createSendMessagePayload = {
            .mock(messageIdSuffix: messageIdSuffix, content: $0, attachment: $1)
        }

        let interactor = Interactor.failing
        interactor.environment.gcd.mainQueue.asyncIfNeeded = { $0() }
        interactor.environment.coreSdk.configureWithInteractor = { _ in }
        interactor.environment.coreSdk.configureWithConfiguration = { _, callback in callback?() }
        interactor.environment.coreSdk.sendMessagePreview = { _, _ in }
        interactor.environment.coreSdk.sendMessageWithMessagePayload = { [weak viewModel] _, completion in
            // Deliver message via socket before REST API response.
            viewModel?.interactorEvent(.receivedMessage(.mock(id: expectedMessageId)))
            completion(.success(.mock(id: expectedMessageId)))
        }
        interactor.environment.coreSdk.queueForEngagement = { _, _, _, _, _, completion in
            completion(.mock, nil)
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
