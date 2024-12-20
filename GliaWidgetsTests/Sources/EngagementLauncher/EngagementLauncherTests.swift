import XCTest

@testable import GliaWidgets

final class EngagementLauncherTests: XCTestCase {

    func test_startChat() throws {
        var chatEngagement: EngagementKind?
        let engagementLauncher = EngagementLauncher { engagementKind, _ in
            chatEngagement = engagementKind
        }

        try engagementLauncher.startChat()

        XCTAssertEqual(chatEngagement, .chat)
    }

    func test_startAudioCall() throws {
        var chatEngagement: EngagementKind?
        let engagementLauncher = EngagementLauncher { engagementKind, _ in
            chatEngagement = engagementKind
        }

        try engagementLauncher.startAudioCall()

        XCTAssertEqual(chatEngagement, .audioCall)
    }

    func test_startVideoCall() throws {
        var chatEngagement: EngagementKind?
        let engagementLauncher = EngagementLauncher { engagementKind, _ in
            chatEngagement = engagementKind
        }

        try engagementLauncher.startVideoCall()
        
        XCTAssertEqual(chatEngagement, .videoCall)
    }

    func test_startSecureMessaging() throws {
        var chatEngagement: EngagementKind?
        let engagementLauncher = EngagementLauncher { engagementKind, _ in
            chatEngagement = engagementKind
        }

        try engagementLauncher.startSecureMessaging()
        
        XCTAssertEqual(chatEngagement, .messaging(.welcome))
    }
}
