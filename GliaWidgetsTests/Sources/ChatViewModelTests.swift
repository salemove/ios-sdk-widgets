@testable import GliaWidgets
import SalemoveSDK
import XCTest

class ChatViewModelTests: XCTestCase {

    var viewModel: ChatViewModel!

    func test__choiceOptionSelected() throws {

        enum Call { case sendSelectedOptionValue }
        var calls = [Call]()

        var fileManager = FoundationBased.FileManager.failing
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [URL(fileURLWithPath: "/i/m/mocked/url")] }
        fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
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
            shouldSkipEnqueueingState: false,
            environment: .init(
                fetchFile: { _, _, _ in },
                downloadSecureFile: { _, _, _ in .mock },
                sendSelectedOptionValue: { _, _ in
                    calls.append(.sendSelectedOptionValue)
                },
                uploadFileToEngagement: { _, _, _ in },
                fileManager: fileManager,
                data: .failing,
                date: { Date.mock },
                gcd: .failing,
                localFileThumbnailQueue: .failing,
                uiImage: .failing,
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
                startSocketObservation: { },
                stopSocketObservation: { }
            )
        )

        let choiceCardMock = try ChatChoiceCardOption.mock()
        viewModel.sendChoiceCardResponse(choiceCardMock, to: "mocked-message-id")

        XCTAssertEqual(calls, [.sendSelectedOptionValue])
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
        var viewModelEnv = ChatViewModel.Environment.failing(fetchChatHistory: { $0(.success([]))})
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
        enum Call: Equatable { case linkTapped(URL) }
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        let viewModel: ChatViewModel = .mock(
            interactor: .mock(),
            environment: viewModelEnv
        )

        viewModel.delegate = { event in
            switch event {
            case .openLink(let url):
                calls.append(.linkTapped(url))

            default:
                break
            }
        }

        let linkUrl = URL(string: "https://mock.mock")!
        viewModel.linkTapped(linkUrl)

        XCTAssertEqual(calls, [.linkTapped(linkUrl)])
    }

    func test_handleUrlWithRandomSchemeDoesNothing() throws {
        enum Call: Equatable {
            case linkTapped(URL)
            case openUrl(URL)
        }
    
        var calls: [Call] = []
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.createFileUploadListModel = { _ in .mock() }
        viewModelEnv.uiApplication.canOpenURL = { _ in true }
        viewModelEnv.uiApplication.open = {
            calls.append(.openUrl($0))
        }
        let viewModel: ChatViewModel = .mock(interactor: .mock(), environment: viewModelEnv)
        viewModel.delegate = { event in
            switch event {
            case .openLink(let url):
                calls.append(.linkTapped(url))

            default:
                break
            }
        }
    
        let mockUrl = URL(string: "mock:mock")!
        viewModel.linkTapped(mockUrl)

        XCTAssertEqual(calls, [])
    }

    func test_deliveryStatusText() {
        let deliveredStatusText = "This message has been delivered"
        let messageContent = "Message"

        var environment: Interactor.Environment = .mock
        environment.coreSdk.sendMessageWithAttachment = { message, attachment, completion in
            let coreSdkMessage = Message(
                id: UUID().uuidString,
                content: messageContent,
                sender: MessageSender.mock,
                metadata: nil
            )
            completion(coreSdkMessage, nil)
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
        chatViewModelEnv.fetchChatHistory = { _ in }
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
}

extension ChatChoiceCardOption {
    static func mock() throws -> ChatChoiceCardOption {
        // SalemoveSDK.SingleChoiceOption has no available constructors but supports Codable
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
