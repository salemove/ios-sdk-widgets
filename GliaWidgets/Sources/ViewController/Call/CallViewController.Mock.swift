#if DEBUG
import UIKit

extension CallViewController {
    static func mock(
        viewModel: CallViewModel = .mock(),
        viewFactory: ViewFactory = .mock()
    ) -> CallViewController {
        .init(
            viewModel: viewModel,
            viewFactory: viewFactory,
            environment: .init(
                uiApplication: .mock,
                uiScreen: .mock,
                uiDevice: .mock,
                notificationCenter: .mock
            )
        )
    }

    static func mockAudioCallQueueState() throws -> CallViewController {
        let conf = Configuration.mock()
        let queueId = UUID.mock.uuidString
        let interactorEnv = Interactor.Environment.mock
        let interactor = Interactor.mock(
            configuration: conf,
            queueId: queueId,
            environment: interactorEnv
        )
        let alertConf = AlertConfiguration.mock()
        let screenShareHandler = ScreenShareHandler.mock
        let callKind = CallKind.audio
        let callEnv = Call.Environment.mock
        let call = Call.mock(kind: callKind, environment: callEnv)
        let unreadMessages = ObservableValue<Int>.init(with: .zero)
        let startAction = CallViewModel.StartAction.engagement(mediaType: .audio)
        let viewModel = CallViewModel.mock(
            interactor: interactor,
            alertConfiguration: alertConf,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        let theme = Theme.mock()
        let viewFactEnv = ViewFactory.Environment.mock
        let viewFactory: ViewFactory = .mock(
            theme: theme,
            environment: viewFactEnv
        )
        let viewController = CallViewController.mock(viewModel: viewModel, viewFactory: viewFactory)
        viewModel.action?(.queue)
        return viewController
    }

    static func mockAudioCallConnectingState() throws -> CallViewController {
        let conf = Configuration.mock()
        let queueId = UUID.mock.uuidString
        let interactorEnv = Interactor.Environment.mock
        let interactor = Interactor.mock(
            configuration: conf,
            queueId: queueId,
            environment: interactorEnv
        )
        let alertConf = AlertConfiguration.mock()
        let screenShareHandler = ScreenShareHandler.mock
        let callKind = CallKind.audio
        let callEnv = Call.Environment.mock
        let call = Call.mock(kind: callKind, environment: callEnv)
        let unreadMessages = ObservableValue<Int>.init(with: .zero)
        let startAction = CallViewModel.StartAction.engagement(mediaType: .audio)
        let viewModel = CallViewModel.mock(
            interactor: interactor,
            alertConfiguration: alertConf,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        let theme = Theme.mock()
        let viewFactEnv = ViewFactory.Environment.mock
        let viewFactory: ViewFactory = .mock(
            theme: theme,
            environment: viewFactEnv
        )
        let viewController = CallViewController.mock(viewModel: viewModel, viewFactory: viewFactory)
        viewModel.action?(.connecting(name: "Blob The Operator", imageUrl: nil))
        return viewController
    }

    static func mockAudioCallConnectedState() throws -> CallViewController {
        let conf = Configuration.mock()
        let queueId = UUID.mock.uuidString
        var interactorEnv = Interactor.Environment.mock
        interactorEnv.coreSdk.configureWithConfiguration = { _, callback in
            callback?()
        }
        let interactor = Interactor.mock(
            configuration: conf,
            queueId: queueId,
            environment: interactorEnv
        )
        let alertConf = AlertConfiguration.mock()
        let screenShareHandler = ScreenShareHandler.mock
        let callKind = CallKind.audio
        let callEnv = Call.Environment.mock
        let call = Call.mock(kind: callKind, environment: callEnv)
        let remoteAudioStream = CoreSdkClient.MockAudioStreamable.mock(
            muteFunc: {},
            unmuteFunc: {},
            getIsMutedFunc: { false },
            setIsMutedFunc: { _ in },
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
        let unreadMessages = ObservableValue<Int>.init(with: .zero)
        let startAction = CallViewModel.StartAction.engagement(mediaType: .audio)
        let viewModel = CallViewModel.mock(
            interactor: interactor,
            alertConfiguration: alertConf,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        let theme = Theme.mock()
        let viewFactEnv = ViewFactory.Environment.mock
        let viewFactory: ViewFactory = .mock(
            theme: theme,
            environment: viewFactEnv
        )
        let viewController = CallViewController.mock(viewModel: viewModel, viewFactory: viewFactory)
        call.updateAudioStream(with: remoteAudioStream)
        call.updateAudioStream(with: localAudioStream)
        viewModel.action?(.connected(name: "Blob The Operator", imageUrl: nil))
        return viewController
    }

    static func mockVideoCallConnectingState() throws -> CallViewController {
        let conf = Configuration.mock()
        let queueId = UUID.mock.uuidString
        let interactorEnv = Interactor.Environment.mock
        let interactor = Interactor.mock(
            configuration: conf,
            queueId: queueId,
            environment: interactorEnv
        )
        let alertConf = AlertConfiguration.mock()
        let screenShareHandler = ScreenShareHandler.mock
        let callKind = CallKind.video(direction: .oneWay)
        let callEnv = Call.Environment.mock
        let call = Call.mock(kind: callKind, environment: callEnv)
        let unreadMessages = ObservableValue<Int>.init(with: .zero)
        let startAction = CallViewModel.StartAction.engagement(mediaType: .audio)
        let viewModel = CallViewModel.mock(
            interactor: interactor,
            alertConfiguration: alertConf,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        let theme = Theme.mock()
        var viewFactEnv = ViewFactory.Environment.mock
        viewFactEnv.imageViewCache.getImageForKey = { _ in .mock }
        viewFactEnv.timerProviding.scheduledTimerWithTimeIntervalAndRepeats = { _, _, callback in
            // make timer fire 3 times
            for _ in 0 ..< 3 {
                callback(.mock)
            }
            return .mock
        }
        let viewFactory: ViewFactory = .mock(
            theme: theme,
            environment: viewFactEnv
        )
        let viewController = CallViewController.mock(viewModel: viewModel, viewFactory: viewFactory)
        let operatorImageURL = URL.mock
            .appendingPathComponent("operator")
            .appendingPathComponent("123")
            .appendingPathComponent("avatar")
            .appendingPathExtension("png")
        viewModel.action?(.connecting(name: "Blobby Blob", imageUrl: operatorImageURL.absoluteString))
        return viewController
    }

    static func mockVideoCallQueueState() throws -> CallViewController {
        let conf = Configuration.mock()
        let queueId = UUID.mock.uuidString
        let interactorEnv = Interactor.Environment.mock
        let interactor = Interactor.mock(
            configuration: conf,
            queueId: queueId,
            environment: interactorEnv
        )
        let alertConf = AlertConfiguration.mock()
        let screenShareHandler = ScreenShareHandler.mock
        let callKind = CallKind.video(direction: .oneWay)
        let callEnv = Call.Environment.mock
        let call = Call.mock(kind: callKind, environment: callEnv)
        let unreadMessages = ObservableValue<Int>.init(with: .zero)
        let startAction = CallViewModel.StartAction.engagement(mediaType: .audio)
        let viewModel = CallViewModel.mock(
            interactor: interactor,
            alertConfiguration: alertConf,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction
        )
        let theme = Theme.mock()
        let viewFactEnv = ViewFactory.Environment.mock
        let viewFactory: ViewFactory = .mock(
            theme: theme,
            environment: viewFactEnv
        )
        let viewController = CallViewController.mock(viewModel: viewModel, viewFactory: viewFactory)
        viewModel.action?(.queue)
        return viewController
    }

    static func mockVideoCallConnectedState() throws -> CallViewController {
        let conf = Configuration.mock()
        let queueId = UUID.mock.uuidString
        let interactorEnv = Interactor.Environment.mock
        let interactor = Interactor.mock(
            configuration: conf,
            queueId: queueId,
            environment: interactorEnv
        )
        let alertConf = AlertConfiguration.mock()
        let screenShareHandler = ScreenShareHandler.mock
        let callKind = CallKind.video(direction: .oneWay)
        let callEnv = Call.Environment.mock
        let call = Call.mock(kind: callKind, environment: callEnv)
        let unreadMessages = ObservableValue<Int>.init(with: .zero)
        let startAction = CallViewModel.StartAction.engagement(mediaType: .video)
        var callViewModelEnv = CallViewModel.Environment.mock
        callViewModelEnv.timerProviding.scheduledTimerWithTimeIntervalAndTarget = { _, target, _, _, _ in
            (target as? GliaWidgets.CallDurationCounter)?.update()
            return .mock
        }
        let viewModel = CallViewModel.mock(
            interactor: interactor,
            alertConfiguration: alertConf,
            screenShareHandler: screenShareHandler,
            call: call,
            unreadMessages: unreadMessages,
            startWith: startAction,
            environment: callViewModelEnv
        )
        let theme = Theme.mock()
        let viewFactEnv = ViewFactory.Environment.mock
        let viewFactory: ViewFactory = .mock(
            theme: theme,
            environment: viewFactEnv
        )
        let viewController = CallViewController.mock(viewModel: viewModel, viewFactory: viewFactory)

        call.updateVideoStream(with: CoreSdkClient.MockVideoStreamable.mock())
        call.state.value = .started
        viewModel.action?(.connected(name: "Blobby Blob", imageUrl: nil))
        viewModel.action?(.setButtonEnabled(.chat, enabled: true))
        viewModel.action?(.setButtonBadge(.chat, itemCount: 1))
        viewModel.action?(.switchToVideoMode)
        viewModel.action?(.setButtonEnabled(.video, enabled: true))
        viewModel.action?(.setButtonEnabled(.mute, enabled: true))
        viewModel.action?(.setButtonEnabled(.speaker, enabled: true))
        return viewController
    }
}
#endif
