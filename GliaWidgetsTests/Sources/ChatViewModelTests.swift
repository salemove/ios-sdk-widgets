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
            interactor: try .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: ScreenShareHandler(),
            call: .init(with: nil),
            unreadMessages: .init(with: 0),
            showsCallBubble: true,
            isWindowVisible: .init(with: true),
            startAction: .none,
            environment: .init(
                chatStorage: .failing,
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
                fromHistory: { true },
                fetchSiteConfigurations: { _ in },
                getCurrentEngagement: { nil },
                timerProviding: .mock
            )
        )

        let choiceCardMock = try ChatChoiceCardOption.mock()
        viewModel.sendChoiceCardResponse(choiceCardMock, to: "mocked-message-id")

        XCTAssertEqual(calls, [.sendSelectedOptionValue])
    }

    func test__startCallsSDKConfigureWithInteractorAndСonfigureWithConfiguration() throws {
        var interactorEnv = Interactor.Environment.init(coreSdk: .failing)
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
        var viewModelEnv = ChatViewModel.Environment.failing
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
        viewModelEnv.fromHistory = { true }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        viewModel.start()
        XCTAssertEqual(calls, [.configureWithInteractor, .configureWithConfiguration])
    }

    func test__updateDoesNotCallSDKFetchSiteConfigurationsOnEnqueueingState() throws {
        // Given
        enum Calls { case fetchSiteConfigurations }
        var calls: [Calls] = []
        let interactorEnv = Interactor.Environment.init(coreSdk: .failing)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing
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
        let interactorEnv = Interactor.Environment.init(coreSdk: .failing)
        let interactor = Interactor.mock(environment: interactorEnv)
        var viewModelEnv = ChatViewModel.Environment.failing
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

    func test__sendMessageCallsEnqueueNewEngagementOnNoneState() throws {
        // Given
        enum Call {
            case configureWithConfiguration, configureWithInteractor, queueForEngagement, sendMessage
        }
        var calls: [Call] = []
        var coreSdk = CoreSdkClient.failing
        coreSdk.sendMessagePreview = { _, _ in }
        coreSdk.configureWithConfiguration = { _, completion in
            calls.append(.configureWithConfiguration)
            completion?()
        }
        coreSdk.configureWithInteractor = { _ in
            calls.append(.configureWithInteractor)
        }
        coreSdk.queueForEngagement = { _, _, _, _, _, _ in
            calls.append(.queueForEngagement)
        }
        coreSdk.sendMessageWithAttachment = { _, _, _ in
            calls.append(.sendMessage)
        }
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdk))

        var viewModelEnv = ChatViewModel.Environment.failing
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        // When
        // Sets message text
        viewModel.event(.messageTextChanged("Message"))
        // Puts outgoing message to pending messages and starts enqueueing engagement
        viewModel.event(.sendTapped)

        // Then
        XCTAssertEqual(calls, [
            .configureWithInteractor,
            .configureWithConfiguration,
            .queueForEngagement
        ])
    }

    func _test__sendMessageDoesNotCallEnqueueNewEngagementOnEnqueuedState() throws {
        // Given
        enum Call { case queueForEngagement, sendMessage }
        var calls: [Call] = []
        var coreSdk = CoreSdkClient.failing
        coreSdk.sendMessagePreview = { _, _ in }
        coreSdk.configureWithConfiguration = { _, completion in
            completion?()
        }
        coreSdk.configureWithInteractor = { _ in }
        coreSdk.queueForEngagement = { _, _, _, _, _, _ in
            #warning("Need to call competion after adding public init for QueueTicket core-sdk entity")
            calls.append(.queueForEngagement)
        }
        coreSdk.sendMessageWithAttachment = { _, _, _ in
            calls.append(.sendMessage)
        }
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdk))

        var viewModelEnv = ChatViewModel.Environment.failing
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
        viewModelEnv.chatStorage.isEmpty = { true }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        // When
        // Sets interactor state to enqueued
        viewModel.start()
        // Sets message text
        viewModel.event(.messageTextChanged("Message"))
        // Sends outgoing message
        viewModel.event(.sendTapped)

        // Then
        XCTAssertEqual(calls, [.queueForEngagement])
    }

    func _test__sendMessageDoesNotCallEnqueueNewEngagementOnEngagedState() throws {
        // Given
        enum Call { case queueForEngagement, sendMessage }
        var calls: [Call] = []
        var coreSdk = CoreSdkClient.failing
        coreSdk.sendMessagePreview = { _, _ in }
        coreSdk.configureWithConfiguration = { _, completion in
            completion?()
        }
        coreSdk.configureWithInteractor = { _ in }
        coreSdk.queueForEngagement = { _, _, _, _, _, _ in
            #warning("Need to call competion after adding public init for QueueTicket core-sdk entity")
            calls.append(.queueForEngagement)
        }
        coreSdk.requestEngagedOperator = { completion in
            completion([.mock()], nil)
        }
        coreSdk.sendMessageWithAttachment = { _, _, _ in
            calls.append(.sendMessage)
        }
        let interactor = Interactor.mock(environment: .init(coreSdk: coreSdk))

        var viewModelEnv = ChatViewModel.Environment.failing
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
        viewModelEnv.chatStorage.isEmpty = { true }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)

        // When

        // Sets interactor state to enqueued
        viewModel.start()
        // Sets interactor state to engaged
        interactor.start()
        // Sets message text
        viewModel.event(.messageTextChanged("Message"))
        // Sends outgoing message
        viewModel.event(.sendTapped)

        // Then
        XCTAssertEqual(calls, [.queueForEngagement, .sendMessage])
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
