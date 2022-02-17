//
//  ChatViewModelTests.swift
//  GliaWidgetsTests
//
//  Created by Yurii Dukhovnyi on 18.02.2022.
//

import XCTest

@testable import GliaWidgets

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
                date: { Date.mock }
            )
        )

        viewModel.sendChoiceCardResponse(.mock, to: "mocked-message-id")

        XCTAssertEqual(calls, [.sendSelectedOptionValue])
    }
}

import SalemoveSDK

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
