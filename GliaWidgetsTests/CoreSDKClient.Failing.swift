@testable import GliaWidgets
import XCTest

extension CoreSdkClient {
    static let failing = Self(
        pushNotifications: .failing,
        createAppDelegate: { .failing },
        clearSession: { XCTFail("clearSession") },
        fetchVisitorInfo: { _ in XCTFail("fetchVisitorInfo") },
        updateVisitorInfo: { _, _ in XCTFail("updateVisitorInfo") },
        sendSelectedOptionValue: { _, _ in XCTFail("sendSelectedOptionValue") },
        configureWithConfiguration: { _, _ in XCTFail("configureWithConfiguration") },
        configureWithInteractor: { _ in XCTFail("configureWithInteractor") },
        queueForEngagement: { _, _, _, _, _, _ in XCTFail("queueForEngagement") },
        requestMediaUpgradeWithOffer: { _, _ in XCTFail("requestMediaUpgradeWithOffer") },
        sendMessagePreview: { _, _ in XCTFail("sendMessagePreview") },
        sendMessageWithAttachment: { _, _, _ in XCTFail("sendMessageWithAttachment") },
        cancelQueueTicket: { _, _ in XCTFail("cancelQueueTicket") },
        endEngagement: { _ in XCTFail("endEngagement") },
        requestEngagedOperator: { _ in XCTFail("requestEngagedOperator") },
        uploadFileToEngagement: { _, _, _ in XCTFail("uploadFileToEngagement") },
        fetchFile: { _, _, _ in XCTFail("fetchFile") }
    )
}

extension CoreSdkClient.PushNotifications {
    static let failing = Self(
        applicationDidRegisterForRemoteNotificationsWithDeviceToken: { _, _ in
            XCTFail("applicationDidRegisterForRemoteNotificationsWithDeviceToken")
        }
    )
}

extension CoreSdkClient.AppDelegate {
    static let failing = Self(
        applicationDidFinishLaunchingWithOptions: { _, _ in
            XCTFail("applicationDidFinishLaunchingWithOptions")
            return false
        },
        applicationDidBecomeActive: { _ in
            XCTFail("applicationDidBecomeActive")
        }
    )
}
