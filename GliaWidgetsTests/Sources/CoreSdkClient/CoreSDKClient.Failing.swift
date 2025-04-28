@testable import GliaWidgets

extension CoreSdkClient {
    static let failing = Self(
        pushNotifications: .failing,
        liveObservation: .failing,
        secureConversations: .failing,
        createAppDelegate: { .failing },
        clearSession: { fail("\(Self.self).clearSession") },
        localeProvider: .failing,
        getVisitorInfo: { _ in fail("\(Self.self).getVisitorInfo") },
        updateVisitorInfo: { _, _ in fail("\(Self.self).updateVisitorInfo") },
        configureWithConfiguration: { _, _ in fail("\(Self.self).configureWithConfiguration") },
        configureWithInteractor: { _ in fail("\(Self.self).configureWithInteractor") },
        getQueues: { _ in fail("\(Self.self).listQueues") },
        queueForEngagement: { _, _, _ in fail("\(Self.self).queueForEngagement") },
        requestMediaUpgradeWithOffer: { _, _ in fail("\(Self.self).requestMediaUpgradeWithOffer") },
        sendMessagePreview: { _, _ in fail("\(Self.self).sendMessagePreview") },
        sendMessageWithMessagePayload: { _, _ in fail("\(Self.self).sendMessageWithMessagePayload") },
        cancelQueueTicket: { _, _ in fail("cancelQueueTicket") },
        endEngagement: { _ in fail("\(Self.self).endEngagement") },
        requestEngagedOperator: { _ in fail("\(Self.self).requestEngagedOperator") },
        uploadFileToEngagement: { _, _, _ in fail("\(Self.self).uploadFileToEngagement") },
        fetchFile: { _, _, _ in fail("\(Self.self).fetchFile") },
        getCurrentEngagement: { return nil },
        fetchSiteConfigurations: { _ in fail("\(Self.self).fetchSiteConfigurations") },
        submitSurveyAnswer: { _, _, _, _ in },
        authentication: { _ in
            fail("\(Self.self).authentication")
            return .mock
        },
        fetchChatHistory: { _ in },
        requestVisitorCode: { _ in
            fail("\(Self.self).requestVisitorCode")
            return .init()
        },
        startSocketObservation: {
            fail("\(Self.self).startSocketObservation")
        },
        stopSocketObservation: {
            fail("\(Self.self).stopSocketObservation")
        },
        createSendMessagePayload: { _, _ in
            fail("\(Self.self).createSendMessagePayload")
            return .mock()
        },
        createLogger: { _ in
            fail("\(Self.self).createLogger")
            return Logger.mock
        },
        getCameraDeviceManageable: {
            .failing
        },
        subscribeForQueuesUpdates: { _, _ in
            fail("\(Self.self).subscribeForQueuesUpdates")
            return ""
        },
        unsubscribeFromUpdates: { _, _ in
            fail("\(Self.self).unsubscribeFromUpdates")
        },
        configureLogLevel: { _ in
            fail("\(Self.self).configureLogLevel")
        }
    )
}

extension CoreSdkClient.SecureConversations {
    static let failing = Self(
        sendMessagePayload: { _, _, _ in
            fail("\(Self.self).sendMessagePayload")
            return .mock
        },
        uploadFile: { _, _, _ in
            fail("\(Self.self).uploadFile")
            return .mock
        },
        getUnreadMessageCount: { _ in
            fail("\(Self.self).getUnreadMessageCount")
        },
        markMessagesAsRead: { _ in
            fail("\(Self.self).markMessagesAsRead")
            return .mock
        },
        downloadFile: { _, _, _ in
            fail("\(Self.self).downloadFile")
            return .mock
        },
        subscribeForUnreadMessageCount: { _ in
            fail("\(Self.self).subscribeForUnreadMessageCount")
            return ""
        },
        unsubscribeFromUnreadMessageCount: { _ in
            fail("\(Self.self).unsubscribeFromUnreadCount")
        },
        pendingStatus: { _ in
            fail("\(Self.self).pendingStatus")
        },
        observePendingStatus: { _ in
            fail("\(Self.self).observePendingStatus")
            return nil
        },
        unsubscribeFromPendingStatus: { _ in
            fail("\(Self.self).unsubscribeFromPendingStatus")
        }
    )
}

extension CoreSdkClient.LiveObservation {
    static let failing = Self(
        pause: {
            fail("\(Self.self).pause")
        }, resume: {
            fail("\(Self.self).resume")
        }
    )
}

extension CoreSdkClient.PushNotifications {
    static let failing = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken: { _, _ in
            fail("\(Self.self).applicationDidRegisterForRemoteNotificationsWithDeviceToken")
        },
        applicationDidFailToRegisterForRemoteNotificationsWithError: { _, _ in
            fail("\(Self.self).applicationDidFailToRegisterForRemoteNotificationsWithError")
        },
        setPushHandler: { _ in
            fail("\(Self.self).setPushHandler")
        },
        pushHandler: {
            fail("\(Self.self).pushHandler")
            return nil
        },
        subscribeTo: { _ in
            fail("\(Self.self).subscribeTo")
        },
        actions: .init(
            setSecureMessageAction: { _ in },
            secureMessageAction: { return nil }
        )
    )
}

extension CoreSdkClient.AppDelegate {
    static let failing = Self(
        applicationDidFinishLaunchingWithOptions: { _, _ in
            fail("\(Self.self).applicationDidFinishLaunchingWithOptions")
            return false
        },
        applicationDidBecomeActive: { _ in
            fail("\(Self.self).applicationDidBecomeActive")
        }
    )
}

extension CoreSdkClient.LocaleProvider {
    static let failing = Self(
        getRemoteString: { _ in
            fail("\(Self.self).getRemoteString")
            return nil
        }
    )
}

extension CoreSdkClient.Logger {
    static let failing = Self(
        oneTimeClosure: {
            fail("\(Self.self).oneTimeClosure")
            return Self.mock
        },
        prefixedClosure: { _ in
            fail("\(Self.self).prefixedClosure")
            return Self.mock
        },
        localLoggerClosure: {
            fail("\(Self.self).localLoggerClosure")
            return nil
        },
        remoteLoggerClosure: {
            fail("\(Self.self).remoteLoggerClosure")
            return nil
        },
        errorClosure: { _, _, _, _ in
            fail("\(Self.self).errorClosure")
        },
        warningClosure: { _, _, _, _ in
            fail("\(Self.self).warningClosure")
        },
        infoClosure: { _, _, _, _ in
            fail("\(Self.self).infoClosure")
        },
        debugClosure: { _, _, _, _ in
            fail("\(Self.self).debugClosure")
        },
        configureLocalLogLevelClosure: { _ in
            fail("\(Self.self).configureLocalLogLevelClosure")
        },
        configureRemoteLogLevelClosure: {_ in
            fail("\(Self.self).configureLocalLogLevelClosure")
        },
        reportDeprecatedMethodClosure: { _, _, _, _ in
            fail("\(Self.self).reportDeprecatedMethodClosure")
        }
    )
}

extension CoreSdkClient.CameraDeviceManageableClient {
    static let failing = Self(
        setCameraDevice: { _ in
            fail("\(Self.self).setCameraDevice")
        },
        cameraDevices: {
            fail("\(Self.self).cameraDevices")
            return []
        },
        currentCameraDevice: {
            fail("\(Self.self).currentCameraDevice")
            return nil
        }
    )
}
