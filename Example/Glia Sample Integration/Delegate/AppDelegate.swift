import SalemoveSDK
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    private let gliaDelegate = GliaCore.AppDelegate()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        gliaDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        GliaCore.sharedInstance.pushNotifications.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        gliaDelegate.applicationDidBecomeActive(application)
    }
}
