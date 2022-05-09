import XCTest

@testable import GliaWidgets

class CallViewModelTests: XCTestCase {
    var viewModel: CallViewModel!
    var call: Call!

    func test_setCallOnHoldPausesLocalVideoAndMutesLocalAudio() throws {
        var isVideoButtonEnabled: Bool = true
        var isMuteButtonEnabled: Bool = true
        var isLocalAudioStreamMuted: Bool = false
        var isLocalVideoStreamPaused: Bool = false

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: try .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: ScreenShareHandler(),
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

        viewModel.action = {
            switch $0 {
            case .setButtonEnabled(let button, let isEnabled):
                switch button {
                case .video:
                    isVideoButtonEnabled = isEnabled

                case .mute:
                    isMuteButtonEnabled = isEnabled
                
                default:
                    break
                }
            default:
                break
            }
        }

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
            muteFunc: { isLocalAudioStreamMuted = true },
            unmuteFunc: { isLocalAudioStreamMuted = false },
            getIsMutedFunc: { isLocalAudioStreamMuted },
            setIsMutedFunc: { isLocalAudioStreamMuted = $0 },
            getIsRemoteFunc: { false },
            setIsRemoteFunc: { _ in }
        )
        
        let localVideoStream = CoreSdkClient.MockVideoStreamable.mock(
            getStreamViewFunc: { .init() },
            playVideoFunc: {},
            pauseFunc: { isLocalVideoStreamPaused = true },
            resumeFunc: { isLocalVideoStreamPaused = false },
            stopFunc: {},
            getIsPausedFunc: { isLocalVideoStreamPaused },
            setIsPausedFunc: { isLocalVideoStreamPaused = $0 },
            getIsRemoteFunc: { false },
            setIsRemoteFunc: { _ in }
        )
        
        call.updateAudioStream(with: remoteAudioStream)
        call.updateVideoStream(with: remoteVideoStream)
        call.updateAudioStream(with: localAudioStream)
        call.updateVideoStream(with: localVideoStream)

        remoteVideoStream.onHold?(true)

        XCTAssertFalse(isVideoButtonEnabled)
        XCTAssertFalse(isMuteButtonEnabled)
        XCTAssertTrue(isLocalVideoStreamPaused)
        XCTAssertTrue(isLocalAudioStreamMuted)
    }

    func test_toggleCallOnHoldRestoresPreviousLocalVideoAndAudioState() throws {
        var isLocalAudioStreamMuted: Bool = false
        var isLocalVideoStreamPaused: Bool = false

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: try .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: ScreenShareHandler(),
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

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
            muteFunc: { isLocalAudioStreamMuted = true },
            unmuteFunc: { isLocalAudioStreamMuted = false },
            getIsMutedFunc: { isLocalAudioStreamMuted },
            setIsMutedFunc: { isLocalAudioStreamMuted = $0 },
            getIsRemoteFunc: { false },
            setIsRemoteFunc: { _ in }
        )
        
        let localVideoStream = CoreSdkClient.MockVideoStreamable.mock(
            getStreamViewFunc: { .init() },
            playVideoFunc: {},
            pauseFunc: { isLocalVideoStreamPaused = true },
            resumeFunc: { isLocalVideoStreamPaused = false },
            stopFunc: {},
            getIsPausedFunc: { isLocalVideoStreamPaused },
            setIsPausedFunc: { isLocalVideoStreamPaused = $0 },
            getIsRemoteFunc: { false },
            setIsRemoteFunc: { _ in }
        )
        
        call.updateAudioStream(with: remoteAudioStream)
        call.updateVideoStream(with: remoteVideoStream)
        call.updateAudioStream(with: localAudioStream)
        call.updateVideoStream(with: localVideoStream)

        XCTAssertFalse(isLocalAudioStreamMuted)
        XCTAssertFalse(isLocalVideoStreamPaused)

        viewModel.event(.callButtonTapped(.mute))
        viewModel.event(.callButtonTapped(.video))

        XCTAssertTrue(isLocalAudioStreamMuted)
        XCTAssertTrue(isLocalVideoStreamPaused)

        remoteAudioStream.onHold?(true)
        remoteAudioStream.onHold?(false)

        XCTAssertTrue(isLocalAudioStreamMuted)
        XCTAssertTrue(isLocalVideoStreamPaused)
    }
    
    func test_engagementTransferredReleasesRemoteAndLocalVideoAndShowsConnectingState() throws {
        enum Calls {
            case setLocalVideoNil
            case setRemoteVideoNil
            case showConnecting
        }
        var calls: [Calls] = []

        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        let interactor: Interactor = .mock(environment: interactorEnv)
        let mockOperator: CoreSdkClient.Operator = .mock()

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: interactor,
            alertConfiguration: .mock(),
            screenShareHandler: ScreenShareHandler(),
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

        viewModel.action = { action in
            switch action {
            case .setLocalVideo(let video):
                if video == nil {
                    calls.append(.setLocalVideoNil)
                }
                
            case .setRemoteVideo(let video):
                if video == nil {
                    calls.append(.setRemoteVideoNil)
                }
                
            case .connecting:
                calls.append(.showConnecting)
                
            default:
                break
            }
        }

        interactor.notify(.engagementTransferred(mockOperator))

        XCTAssertEqual([.setRemoteVideoNil, .setLocalVideoNil, .showConnecting], calls)
    }
}
