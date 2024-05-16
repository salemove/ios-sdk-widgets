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
        XCTAssertFalse(isLocalAudioStreamMuted)
    }

    func test_localVideoIsNotEnabledWhenUpgradingFromAudioToVideoWhileOnHold() throws {
        var isLocalVideoStreamPaused: Bool = false

        call = .init(
            .audio,
            environment: .mock
        )

        let interactor: Interactor = .mock()

        viewModel = .init(
            interactor: interactor,
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
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

        call.updateVideoStream(with: remoteVideoStream)
        call.updateVideoStream(with: localVideoStream)

        remoteVideoStream.onHold?(true)

        XCTAssertTrue(isLocalVideoStreamPaused)

        let offer = try CoreSdkClient.MediaUpgradeOffer(type: .video, direction: .twoWay)

        interactor.notify(.updateOffer(offer))

        XCTAssertTrue(isLocalVideoStreamPaused)
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
        interactorEnv.gcd.mainQueue.async = { $0() }
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
        interactorEnv.gcd.mainQueue.async = { $0() }
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
        interactorEnv.gcd.mainQueue.async = { $0() }
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
    }
    func test_viewModelStartDoesNotInitiateEnqueuingWithStartActionAsEngagement() {
        let viewModel: CallViewModel = .mock()
        viewModel.start()

        XCTAssertEqual(viewModel.interactor.state, .none)
    }

    func test_liveObservationAlertPresentationInitiatedWhenInteractorStateIsEnqueuing() throws {
        enum Call {
            case showLiveObservationAlert
        }
        var calls: [Call] = []
        let interactor: Interactor = .mock()
        let site: CoreSdkClient.Site = try .mock()

        var viewModelEnvironment: EngagementViewModel.Environment = .mock
        viewModelEnvironment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        let viewModel: ChatViewModel = .mock(
            interactor: interactor,
            environment: viewModelEnvironment
        )
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

    func test_liveObservationAllowTriggersEnqueue() throws {
        var interactorEnv: Interactor.Environment = .mock
        interactorEnv.coreSdk.queueForEngagement = { _, completion in
            completion(.success(.mock))
        }

        let interactor: Interactor = .mock(environment: interactorEnv)
        var alertConfig: LiveObservation.Confirmation?
        let site: CoreSdkClient.Site = try .mock()

        var viewModelEnvironment: EngagementViewModel.Environment = .mock
        viewModelEnvironment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        let viewModel: ChatViewModel = .mock(
            interactor: interactor,
            environment: viewModelEnvironment
        )
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

    func test_liveObservationDeclineTriggersNone() throws {
        enum Call {
            case queueForEngagement
        }
        var calls: [Call] = []
        var interactorEnv: Interactor.Environment = .mock
        interactorEnv.coreSdk.queueForEngagement = { _, _ in
            calls.append(.queueForEngagement)
        }

        let interactor: Interactor = .mock(environment: interactorEnv)
        var alertConfig: LiveObservation.Confirmation?
        let site: CoreSdkClient.Site = try .mock()

        var viewModelEnvironment: EngagementViewModel.Environment = .mock
        viewModelEnvironment.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        let viewModel: ChatViewModel = .mock(
            interactor: interactor,
            environment: viewModelEnvironment
        )
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

    func test_proximityManagerStartsAndStops() {
        enum Call: Equatable { case isIdleTimerDisabled(Bool), isProximityMonitoringEnabled(Bool) }
        var calls: [Call] = []
        var env = CallViewModel.Environment.failing()
        var proximityManagerEnv = ProximityManager.Environment.failing
        proximityManagerEnv.uiApplication.isIdleTimerDisabled = { value in
            calls.append(.isIdleTimerDisabled(value))
        }
        proximityManagerEnv.uiDevice.isProximityMonitoringEnabled = { value in
            calls.append(.isProximityMonitoringEnabled(value))
        }
        env.proximityManager = .init(environment: proximityManagerEnv)
        viewModel = .init(
            interactor: .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            environment: env,
            call: .mock(),
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .video)
        )

        viewModel.event(.viewDidLoad)

        XCTAssertEqual(calls, [
            .isIdleTimerDisabled(true),
            .isProximityMonitoringEnabled(true)
        ])

        viewModel = nil
        XCTAssertEqual(calls, [
            .isIdleTimerDisabled(true),
            .isProximityMonitoringEnabled(true),
            .isIdleTimerDisabled(false),
            .isProximityMonitoringEnabled(false)
        ])
    }

    func test_showLocalVideAssignsOnHoldCallbackThatWeaklyCapturesVideoStream() {
        var videoStreamable = CoreSdkClient.MockVideoStreamable.mock()
        weak var weakVideoStreamable = videoStreamable
        let sdk = CallViewModel.mock()
        sdk.callShowLocalVideoForTesting(videoStreamable)
        videoStreamable = .mock()
        XCTAssertNil(weakVideoStreamable)
    }

    func test_localVideoIsPausedWhenUpgradingFromAudioDuringOnHold() throws {
        var isLocalVideoStreamPaused: Bool = false

        call = .init(
            .audio,
            environment: .mock
        )

        viewModel = .init(
            interactor: .mock(),
            alertConfiguration: .mock(),
            screenShareHandler: .mock,
            environment: .mock,
            call: call,
            unreadMessages: .init(with: 0),
            startWith: .engagement(mediaType: .audio)
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
        call.updateVideoStream(with: localVideoStream)

        remoteAudioStream.onHold?(true)
        remoteVideoStream.onHold?(true)

        viewModel.interactorEvent(.updateOffer(try .init(type: .video, direction: .twoWay)))

        XCTAssertTrue(isLocalVideoStreamPaused)
    }

    func test_localVideoIsPresentImmediatelyAfterTwoWayVideoUpgrade() throws {
        var isLocalVideoStreamPaused: Bool = false

        call = .init(
            .audio,
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

        call.updateVideoStream(with: localVideoStream)
        viewModel.interactorEvent(.updateOffer(try .init(type: .video, direction: .twoWay)))

        XCTAssertFalse(isLocalVideoStreamPaused)
    }

    func test_setFlipCameraButtonVisibleWhenHasCameraDeviceManagerInvokesCallback() {
        var cameraDeviceManager = CoreSdkClient.CameraDeviceManageableClient.failing
        let frontCamera = CoreSdkClient.CameraDevice(
            mockName: "FrontCameraMock",
            mockFacing: .front
        )
        let backCamera = CoreSdkClient.CameraDevice(
            mockName: "BackCameraMock",
            mockFacing: .back
        )

        cameraDeviceManager.cameraDevices = {
            [frontCamera, backCamera]
        }

        cameraDeviceManager.currentCameraDevice = { backCamera }

        enum Call {
            case callback
        }

        var calls: [Call] = []

        CallViewModel.setFlipCameraButtonVisible(
            true,
            getCameraDeviceManager: { cameraDeviceManager },
            log: .failing,
            flipCameraButtonStyle: .nop,
            callback: { _ in
                calls.append(.callback)
            })

        XCTAssertEqual(calls, [.callback])
    }

    func test_setFlipCameraButtonVisibleReceivesExpectedAccessibilityForCurrentDevice() {
        var cameraDeviceManager = CoreSdkClient.CameraDeviceManageableClient.failing
        let frontCamera = CoreSdkClient.CameraDevice(
            mockName: "FrontCameraMock",
            mockFacing: .front
        )
        let backCamera = CoreSdkClient.CameraDevice(
            mockName: "BackCameraMock",
            mockFacing: .back
        )

        cameraDeviceManager.cameraDevices = {
            [frontCamera, backCamera]
        }

        var style = FlipCameraButtonStyle.mock
        style.accessibility.switchToBackCameraAccessibilityLabel = "backCamaraLabel"
        style.accessibility.switchToBackCameraAccessibilityHint = "backCameraHint"
        style.accessibility.switchToFrontCameraAccessibilityLabel = "frontCameraLabel"
        style.accessibility.switchToFrontCameraAccessibilityHint = "frontCameraHint"

        cameraDeviceManager.currentCameraDevice = { backCamera }

        var accessibilities: [FlipCameraButton.Props.Accessibility] = []

        CallViewModel.setFlipCameraButtonVisible(
            true,
            getCameraDeviceManager: { cameraDeviceManager },
            log: .failing,
            flipCameraButtonStyle: style,
            callback: {
                if let accessibility = $0?.accessibility {
                    accessibilities.append(accessibility)
                }
            })

        let backCameraExpectedAccessibility = FlipCameraButton.Props.Accessibility(
            accessibilityLabel: style.accessibility.switchToFrontCameraAccessibilityLabel,
            accessibilityHint: style.accessibility.switchToFrontCameraAccessibilityHint
        )

        cameraDeviceManager.currentCameraDevice = { frontCamera }

        CallViewModel.setFlipCameraButtonVisible(
            true,
            getCameraDeviceManager: { cameraDeviceManager },
            log: .failing,
            flipCameraButtonStyle: style,
            callback: {
                if let accessibility = $0?.accessibility {
                    accessibilities.append(accessibility)
                }
            })

        let frontCameraExpectedAccessibility = FlipCameraButton.Props.Accessibility(
            accessibilityLabel: style.accessibility.switchToBackCameraAccessibilityLabel,
            accessibilityHint: style.accessibility.switchToBackCameraAccessibilityHint
        )

        XCTAssertEqual(accessibilities, [backCameraExpectedAccessibility, frontCameraExpectedAccessibility])
    }

    func test_setFlipCameraButtonVisibleGivenVisibleParamAsFalseReceivesNil() {
        var cameraDeviceManager = CoreSdkClient.CameraDeviceManageableClient.failing
        let frontCamera = CoreSdkClient.CameraDevice(
            mockName: "FrontCameraMock",
            mockFacing: .front
        )
        let backCamera = CoreSdkClient.CameraDevice(
            mockName: "BackCameraMock",
            mockFacing: .back
        )

        cameraDeviceManager.cameraDevices = {
            [frontCamera, backCamera]
        }

        var style = FlipCameraButtonStyle.mock
        style.accessibility.switchToBackCameraAccessibilityLabel = "backCamaraLabel"
        style.accessibility.switchToBackCameraAccessibilityHint = "backCameraHint"
        style.accessibility.switchToFrontCameraAccessibilityLabel = "frontCameraLabel"
        style.accessibility.switchToFrontCameraAccessibilityHint = "frontCameraHint"

        cameraDeviceManager.currentCameraDevice = { backCamera }


        var receivedAccessibilitiesWithCallbacks: [VideoStreamView.FlipCameraAccLabelWithTap?] = []

        CallViewModel.setFlipCameraButtonVisible(
            false,
            getCameraDeviceManager: { cameraDeviceManager },
            log: .failing,
            flipCameraButtonStyle: style,
            callback: {
                receivedAccessibilitiesWithCallbacks.append($0)
            })

        XCTAssertEqual(receivedAccessibilitiesWithCallbacks[0]?.tapCallback, nil)
        XCTAssertEqual(receivedAccessibilitiesWithCallbacks[0]?.accessibility, nil)
    }

    func test_setFlipCameraButtonVisibleGivenThrowingGetCameraDeviceManagerLogsWarning() {
        let cameraDeviceManager = CoreSdkClient.CameraDeviceManageableClient.failing
        let style = FlipCameraButtonStyle.mock
        var receivedAccessibilitiesWithCallbacks: [VideoStreamView.FlipCameraAccLabelWithTap?] = []

        var warnings: [String] = []

        var log = CoreSdkClient.Logger.failing
        log.warningClosure = { warning, _, _, _ in
            warnings.append("\(warning)")
        }

        CallViewModel.setFlipCameraButtonVisible(
            false,
            getCameraDeviceManager: { throw CoreSdkClient.CameraDevice.Error.cameraIsNotAccessibleOnStream },
            log: log,
            flipCameraButtonStyle: style,
            callback: {
                receivedAccessibilitiesWithCallbacks.append($0)
            })

        XCTAssertEqual(receivedAccessibilitiesWithCallbacks[0]?.tapCallback, nil)
        XCTAssertEqual(receivedAccessibilitiesWithCallbacks[0]?.accessibility, nil)
        XCTAssertEqual(warnings, ["Unable to access camera device manager: 'cameraIsNotAccessibleOnStream'."])
    }
}
