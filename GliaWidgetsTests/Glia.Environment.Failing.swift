@testable import GliaWidgets
@_spi(GliaWidgets) import GliaCoreSDK

extension Glia.Environment {
    static let failing = Self(
        coreSdk: .failing,
        audioSession: .failing,
        uuid: {
            fail("\(Self.self).uuid")
            return .mock
        }, date: {
            fail("\(Self.self).date")
            return .mock
        },
        fileManager: .failing,
        data: .failing,
        gcd: .failing,
        imageViewCache: .failing,
        createThumbnailGenerator: { .failing },
        createFileDownload: { _, _, _ in .failing },
        loadChatMessagesFromHistory: {
            fail("\(Self.self).loadChatMessagesFromHistory")
            return true
        },
        timerProviding: .failing,
        uiApplication: .failing,
        uiScreen: .failing,
        uiDevice: .failing,
        notificationCenter: .failing,
        createRootCoordinator: { _, _, _, _, _, _, _ in
            fail("\(Self.self).createRootCoordinator")
            return .mock(
                interactor: .mock(environment: .failing),
                viewFactory: .mock(environment: .failing),
                sceneProvider: nil,
                engagementLaunching: .direct(kind: .none),
                screenShareHandler: .mock,
                features: [],
                environment: .failing
            )
        },
        callVisualizerPresenter: .init(presenter: {
            fail("\(Self.self).callVisualizerPresenter")
            return nil
        }),
        bundleManaging: .init(current: {
            fail("\(Self.self).bundleManaging")
            return .main
        }),
        createFileUploader: { _, _ in
            .failing
        },
        createFileUploadListModel: { _ in
            fail("\(Self.self).createFileUploadListModel")
            return .mock()
        },
        screenShareHandler: .mock,
        messagesWithUnreadCountLoaderScheduler: CoreSdkClient.reactiveSwiftDateSchedulerMock,
        orientationManager: .mock(),
        coreSDKConfigurator: .failing,
        proximityManager: .failing,
        print: .failing,
        conditionalCompilation: .failing,
        snackBar: .failing,
        processInfo: .failing,
        cameraDeviceManager: {
            fail("\(Self.self).cameraDeviceManager")
            return .failing
        },
        isAuthenticated: {
            fail("\(Self.self).isAuthenticated")
            return false
        },
        dismissManager: .init { _, _, _ in
            fail("\(Self.self).dismissManager")
        },
        combineScheduler: .mock
    )
}

extension Glia.Environment.AudioSession {
    static let failing = Self(
        overrideOutputAudioPort: { _ in
            fail("\(Self.self).overrideOutputAudioPort")
        }
    )
}
