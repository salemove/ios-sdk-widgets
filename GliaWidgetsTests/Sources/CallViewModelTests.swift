import XCTest

@testable import GliaWidgets

// swiftlint:disable type_body_length
class CallViewModelTests: XCTestCase {
    var viewModel: CallViewModel!
    var call: Call!

    // swiftlint:disable function_body_length
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
            interactor: .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
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

    // swiftlint:disable function_body_length
    func test_toggleCallOnHoldRestoresPreviousLocalVideoAndAudioState() throws {
        var isLocalAudioStreamMuted: Bool = false
        var isLocalVideoStreamPaused: Bool = false

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
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

    func test_engagementTransferringReleasesRemoteAndLocalVideoAndShowsConnectingState() throws {
        enum Calls { case showConnecting }
        var calls: [Calls] = []

        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        let interactor: Interactor = .mock(environment: interactorEnv)

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: interactor,
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

        viewModel.action = { action in
            switch action {
            case .connecting:
                calls.append(.showConnecting)

            case .setRemoteVideo(let video):
                XCTAssertNil(video)

            case .setLocalVideo(let video):
                XCTAssertNil(video)

            default:
                break
            }
        }

        interactor.notify(.engagementTransferring)

        XCTAssertEqual([.showConnecting], calls)
    }

    // swiftlint:disable function_body_length
    func test_engagementTransferringReleasesStreams() throws {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        let interactor: Interactor = .mock(environment: interactorEnv)
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

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: interactor,
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

        call.updateVideoStream(with: localVideoStream)
        call.updateVideoStream(with: remoteVideoStream)
        call.updateAudioStream(with: localAudioStream)
        call.updateAudioStream(with: remoteAudioStream)

        XCTAssertEqual(call.state.value, .started)
        XCTAssertFalse(call.audio.stream.value.localStream == nil)
        XCTAssertFalse(call.audio.stream.value.remoteStream == nil)
        XCTAssertFalse(call.video.stream.value.localStream == nil)
        XCTAssertFalse(call.video.stream.value.remoteStream == nil)

        interactor.notify(.engagementTransferring)

        XCTAssertNil(call.video.stream.value.localStream)
        XCTAssertNil(call.video.stream.value.remoteStream)
        XCTAssertNil(call.audio.stream.value.localStream)
        XCTAssertNil(call.audio.stream.value.remoteStream)
    }

    func test_interactorEventUpdatesCallMediaState() throws {
        var interactorEnv: Interactor.Environment = .failing
        interactorEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        let interactor: Interactor = .mock(environment: interactorEnv)

        let offer = try CoreSdkClient.MediaUpgradeOffer(type: .audio, direction: .oneWay)

        call = .init(
            .video(direction: .twoWay),
            environment: .mock
        )

        viewModel = .init(
            interactor: interactor,
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

        XCTAssertEqual(call.kind.value, .video(direction: .twoWay))

        interactor.notify(.updateOffer(offer))

        XCTAssertEqual(call.kind.value, .audio)
    }

    func test_startMethodDoesNotHandleInteractorStateEnded() {
        let interactor: Interactor = .mock()
        interactor.state = .ended(.byOperator)
        let call: Call = .mock()
        let viewModel: CallViewModel = .mock(interactor: interactor, call: call)

        XCTAssertEqual(call.state.value, .none)
        viewModel.start()

        XCTAssertEqual(call.state.value, .none)
    func test_viewModelStartDoesNotInitiateEnqueuingWithStartActionAsEngagement() {
        let viewModel: CallViewModel = .mock()
        viewModel.start()

        XCTAssertEqual(viewModel.interactor.state, .none)
    }

    func test_liveObservationAlertPresentationInitiatedWhenInteractorStateIsEnqueuing() {
        enum Call {
            case showLiveObservationAlert
        }
        var calls: [Call] = []
        let interactor: Interactor = .mock()
        let viewModel: CallViewModel = .mock(interactor: interactor)
        viewModel.engagementAction = { action in
            switch action {
            case .showLiveObservationConfirmation:
                calls.append(.showLiveObservationAlert)
            default:
                XCTFail()
            }
        }
        interactor.state = .enqueueing(.audio)
        XCTAssertEqual(calls, [.showLiveObservationAlert])
    }

    func test_liveObservationAllowTriggersEnqueue() {
        var interactorEnv: Interactor.Environment = .mock
        interactorEnv.coreSdk.queueForEngagement = { _, completion in
            completion(.success(.mock))
        }

        let interactor: Interactor = .mock(environment: interactorEnv)
        interactor.isConfigurationPerformed = true

        var alertConfig: LiveObservation.Confirmation?

        let viewModel: CallViewModel = .mock(interactor: interactor)
        viewModel.engagementAction = { action in
            switch action {
            case let .showLiveObservationConfirmation(config):
                alertConfig = config
            default:
                XCTFail()
            }
        }
        interactor.state = .enqueueing(.audio)
        alertConfig?.accepted()
        XCTAssertEqual(interactor.state, .enqueued(.mock))
    }

    func test_liveObservationDeclineTriggersNone() {
        enum Call {
            case queueForEngagement
        }
        var calls: [Call] = []
        var interactorEnv: Interactor.Environment = .mock
        interactorEnv.coreSdk.queueForEngagement = { _, _ in
            calls.append(.queueForEngagement)
        }

        let interactor: Interactor = .mock(environment: interactorEnv)
        interactor.isConfigurationPerformed = true

        var alertConfig: LiveObservation.Confirmation?

        let viewModel: CallViewModel = .mock(interactor: interactor)
        viewModel.engagementAction = { action in
            switch action {
            case let .showLiveObservationConfirmation(config):
                alertConfig = config
            default:
                XCTFail()
            }
        }
        interactor.state = .enqueueing(.audio)
        alertConfig?.declined()
        XCTAssertEqual(interactor.state, .ended(.byVisitor))
        XCTAssertTrue(calls.isEmpty)
    }
}
