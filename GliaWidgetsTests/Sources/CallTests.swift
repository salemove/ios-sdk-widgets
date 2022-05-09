@testable import GliaWidgets
import XCTest

class CallTests: XCTestCase {
    func test_transfer() throws {
        let call: Call = .mock(kind: .video(direction: .twoWay), environment: .mock)
        let remoteAudioStream = CoreSdkClient.MockAudioStreamable.mock(
            muteFunc: {},
            unmuteFunc: {},
            getIsMutedFunc: { false },
            setIsMutedFunc: { _ in },
            getIsRemoteFunc: { true },
            setIsRemoteFunc: { _ in }
        )
        let remoteVideoStream = CoreSdkClient.MockVideoStreamable.mock(
            getStreamViewFunc: { .init() },
            playVideoFunc: {},
            pauseFunc: {},
            resumeFunc: {},
            stopFunc: {},
            getIsPausedFunc: { false },
            setIsPausedFunc: { _ in },
            getIsRemoteFunc: { true },
            setIsRemoteFunc: { _ in }
        )
        let localAudioStream = CoreSdkClient.MockAudioStreamable.mock(
            muteFunc: {},
            unmuteFunc: {},
            getIsMutedFunc: { false },
            setIsMutedFunc: { _ in },
            getIsRemoteFunc: { false },
            setIsRemoteFunc: { _ in }
        )
        let localVideoStream = CoreSdkClient.MockVideoStreamable.mock(
            getStreamViewFunc: { .init() },
            playVideoFunc: {},
            pauseFunc: {},
            resumeFunc: {},
            stopFunc: {},
            getIsPausedFunc: { false },
            setIsPausedFunc: { _ in },
            getIsRemoteFunc: { false },
            setIsRemoteFunc: { _ in }
        )

        XCTAssertEqual(call.state.value, .none)

        call.updateAudioStream(with: localAudioStream)
        call.updateAudioStream(with: remoteAudioStream)
        call.updateVideoStream(with: localVideoStream)
        call.updateVideoStream(with: remoteVideoStream)

        XCTAssertEqual(call.state.value, .started)
        XCTAssertFalse(call.audio.stream.value.isNone)
        XCTAssertFalse(call.video.stream.value.isNone)

        call.transfer()

        XCTAssertEqual(call.state.value, .connecting)
        XCTAssertTrue(call.audio.stream.value.isNone)
        XCTAssertTrue(call.video.stream.value.isNone)
    }
}
