@testable import GliaWidgets

extension CoreSdkClient {
    static let failing = Self(
        pushNotifications: .failing,
        liveObservation: .failing,
        secureConversations: .failing,
        createAppDelegate: { .failing },
        clearSession: { fail("\(Self.self).clearSession") },
        localeProvider: .failing,
        configureWithConfiguration: { _, _ in fail("\(Self.self).configureWithConfiguration") },
        getVisitorInfo: {
            fail("\(Self.self).getVisitorInfo")
            throw NSError(domain: "getVisitorInfo", code: -1, userInfo: nil)
        },
        updateVisitorInfo: { _ in
            fail("\(Self.self).updateVisitorInfo")
            throw NSError(domain: "updateVisitorInfo", code: -1, userInfo: nil)
        },
        configureWithInteractor: { _ in fail("\(Self.self).configureWithInteractor") },
        getQueues: {
            fail("\(Self.self).getQueues")
            throw NSError(domain: "getQueues", code: -1)
        },
        queueForEngagement: { _, _ in
            fail("\(Self.self).queueForEngagement")
            throw NSError(domain: "queueForEngagement", code: -1, userInfo: nil)
        },
        sendMessagePreview: { _ in
            fail("\(Self.self).sendMessagePreview")
            throw NSError(domain: "CoreSdkClient", code: -1, userInfo: nil)
        },
        sendMessageWithMessagePayload: { _ in fail("\(Self.self).sendMessageWithMessagePayload")
            throw NSError(domain: "CoreSdkClient", code: -1, userInfo: nil)
        },
        cancelQueueTicket: { _ in
            fail("cancelQueueTicket")
            throw NSError(domain: "cancelQueueTicket", code: -1, userInfo: nil)
        },
        endEngagement: {
            fail("\(Self.self).endEngagement")
            throw NSError(domain: "endEngagement", code: -1)
        },
        requestEngagedOperator: {
            fail("\(Self.self).requestEngagedOperator")
            throw NSError(domain: "requestEngagedOperator", code: -1)
        },
        uploadFileToEngagement: { _, _, _ in fail("\(Self.self).uploadFileToEngagement") },
        fetchFile: { _, _ in
            fail("\(Self.self).fetchFile")
            throw NSError(domain: "fetchFile", code: -1)
        },
        getCurrentEngagement: { return nil },
        fetchSiteConfigurations: { _ in fail("\(Self.self).fetchSiteConfigurations") },
        submitSurveyAnswer: { _, _, _ in
            fail("\(Self.self).submitSurveyAnswer")
            throw NSError(domain: "submitSurveyAnswer", code: -1)
        },
        authentication: { _ in
            fail("\(Self.self).authentication")
            return .mock
        },
        fetchChatHistory: { [] },
        requestVisitorCode: {
            fail("\(Self.self).requestVisitorCode")
            throw NSError(domain: "requestVisitorCode", code: -1)
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
        sendMessagePayload: { _, _ in
            fail("\(Self.self).sendMessagePayload")
            throw NSError(domain: "sendMessagePayload", code: -1)
        },
        uploadFile: { _, _, _ in
            fail("\(Self.self).uploadFile")
            return .mock
        },
        getUnreadMessageCount: {
            fail("\(Self.self).getUnreadMessageCount")
            throw NSError(domain: "getUnreadMessageCount", code: -1)
        },
        markMessagesAsRead: {
            fail("\(Self.self).markMessagesAsRead")
            throw NSError(domain: "markMessagesAsRead", code: -1)
        },
        downloadFile: { _, _ in
            fail("\(Self.self).downloadFile")
            throw NSError(domain: "downloadFile", code: -1)
        },
        subscribeForUnreadMessageCount: { _ in
            fail("\(Self.self).subscribeForUnreadMessageCount")
            return ""
        },
        unsubscribeFromUnreadMessageCount: { _ in
            fail("\(Self.self).unsubscribeFromUnreadCount")
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
        ),
        userNotificationCenterWillPresent: { _, _, _ in },
        userNotificationCenterDidReceiveResponse: { _, _, _ in }
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
