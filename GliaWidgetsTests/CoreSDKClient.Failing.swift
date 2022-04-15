@testable import GliaWidgets

extension CoreSdkClient {
    static let failing = Self(
        pushNotifications: .failing,
        createAppDelegate: { .failing },
        clearSession: { fail("\(Self.self).clearSession") },
        fetchVisitorInfo: { _ in fail("\(Self.self).fetchVisitorInfo") },
        updateVisitorInfo: { _, _ in fail("\(Self.self).updateVisitorInfo") },
        sendSelectedOptionValue: { _, _ in fail("\(Self.self).sendSelectedOptionValue") },
        configureWithConfiguration: { _, _ in fail("\(Self.self).configureWithConfiguration") },
        configureWithInteractor: { _ in fail("\(Self.self).configureWithInteractor") },
        queueForEngagement: { _, _, _, _, _, _ in fail("\(Self.self).queueForEngagement") },
        requestMediaUpgradeWithOffer: { _, _ in fail("\(Self.self).requestMediaUpgradeWithOffer") },
        sendMessagePreview: { _, _ in fail("\(Self.self).sendMessagePreview") },
        sendMessageWithAttachment: { _, _, _ in fail("\(Self.self).sendMessageWithAttachment") },
        cancelQueueTicket: { _, _ in fail("cancelQueueTicket") },
        endEngagement: { _ in fail("\(Self.self).endEngagement") },
        requestEngagedOperator: { _ in fail("\(Self.self).requestEngagedOperator") },
        uploadFileToEngagement: { _, _, _ in fail("\(Self.self).uploadFileToEngagement") },
        fetchFile: { _, _, _ in fail("\(Self.self).fetchFile") },
        getCurrentEngagement: { return nil },
        fetchSiteConfigurations: { _ in fail("\(Self.self).fetchSiteConfigurations") }
    )
}

extension CoreSdkClient.PushNotifications {
    static let failing = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken: { _, _ in
            fail("\(Self.self).applicationDidRegisterForRemoteNotificationsWithDeviceToken")
        }
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
