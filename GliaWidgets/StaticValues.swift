import Foundation

final class StaticValues {
    /// Current SDK version. This version gets synced with the Info.plist version
    /// when incrementing the version through Fastlane. Unlike the Info.plist, this
    /// version cannot be changed by integrators, so this ensures that our code will
    /// always have the correct version regardless of what our integrators do with
    /// our plist files.
    static let sdkVersion = "0.10.11"
}
