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
                fromHistory: { true }
            )
        )

        viewModel.sendChoiceCardResponse(.mock, to: "mocked-message-id")

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
        var viewModelEnv = ChatViewModel.Environment.failing
        viewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        viewModelEnv.fileManager.createDirectoryAtUrlWithIntermediateDirectories = { _, _, _ in }
        viewModelEnv.chatStorage.messages = { _ in [] }
        viewModelEnv.fromHistory = { true }
        let viewModel = ChatViewModel.mock(interactor: interactor, environment: viewModelEnv)
        viewModel.start()
        XCTAssertEqual(calls, [.configureWithInteractor, .configureWithConfiguration])
    }
}

extension ChatChoiceCardOption {
    static let mock: ChatChoiceCardOption = {
        // SalemoveSDK.SingleChoiceOption has no available constructors but supports Codable
        //  protocol, so I decided that this is the most convenient way to get the instance of.
        let json = """
        { "text": "choice card text", "value": "choice card value" }
        """.utf8
        let mockedOption = try! JSONDecoder().decode(SingleChoiceOption.self, from: Data(json))
        return .init(with: mockedOption)
    }()
}
