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
        let chatStorage = Glia.Environment.ChatStorage.failing
        viewModel = .init(
            interactor: .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: ScreenShareHandler(),
            call: .init(with: nil),
            unreadMessages: .init(with: 0),
            showsCallBubble: true,
            isCustomCardSupported: false,
            isWindowVisible: .init(with: true),
            startAction: .none,
            chatStorageState: { .unauthenticated(chatStorage) },
            deliveredStatusText: "Delivered",
            environment: .init(
                chatStorage: chatStorage,
                fetchFile: { _, _, _ in },
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
                fetchChatHistory: { _ in }
            )
        )

        let choiceCardMock = try ChatChoiceCardOption.mock()
        viewModel.sendChoiceCardResponse(choiceCardMock, to: "mocked-message-id")

        XCTAssertEqual(calls, [.sendSelectedOptionValue])
    }

    func test__startCallsSDKConfigureWithInteractorAndСonfigureWithConfiguration() throws {
        var interactorEnv = Interactor.Environment.init(
            coreSdk: .failing,
            gcd: .failing
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
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
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
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
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
        viewModelEnv.chatStorage.messages = { _ in [] }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }

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
        viewModelEnv.chatStorage.messages = { _ in [] }
        viewModelEnv.loadChatMessagesFromHistory = { true }
        viewModelEnv.fetchSiteConfigurations = { _ in }

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

    func test__updateDoesNotCallSDKFetchSiteConfigurationsOnEnqueueingState() throws {
        // Given
        enum Calls { case fetchSiteConfigurations }
        var calls: [Calls] = []
        let interactorEnv = Interactor.Environment(coreSdk: .failing, gcd: .mock)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing()
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
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
