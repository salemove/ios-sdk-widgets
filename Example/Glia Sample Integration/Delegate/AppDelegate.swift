import GliaCoreSDK
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    private let gliaCoreAppDelegate = GliaCoreAppDelegate()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        gliaCoreAppDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        GliaCore.sharedInstance.pushNotifications.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        gliaCoreAppDelegate.applicationDidBecomeActive(application)
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }
}
