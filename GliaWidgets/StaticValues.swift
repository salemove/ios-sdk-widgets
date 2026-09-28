@_spi(GliaWidgets) internal import GliaCoreSDK
import Foundation

public enum StaticValues {
    /// Current SDK version. This version gets synced with the Info.plist version
    /// when incrementing the version through Fastlane. Unlike the Info.plist, this
    /// version cannot be changed by integrators, so this ensures that our code will
    /// always have the correct version regardless of what our integrators do with
    /// our plist files.
    public static let sdkVersion = "3.5.9"

    /// The version of GliaCoreSDK embedded in GliaWidgets.
    @_spi(GliaTestApp)
    public static var coreSDKVersion: String {
        let bundle = Bundle(for: GliaCore.self)
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
