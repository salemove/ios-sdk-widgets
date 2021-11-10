import UIKit

enum Asset {
    static let alertClose: UIImage? = UIImage(named: "alertClose", in: BundleToken.bundle, compatibleWith: nil)
    static let callChat: UIImage? = UIImage(named: "call-chat", in: BundleToken.bundle, compatibleWith: nil)
    static let callMiminize: UIImage? = UIImage(named: "call-miminize", in: BundleToken.bundle, compatibleWith: nil)
    static let callMuteActive: UIImage? = UIImage(named: "call-mute-active", in: BundleToken.bundle, compatibleWith: nil)
    static let callMuteInactive: UIImage? = UIImage(named: "call-mute-inactive", in: BundleToken.bundle, compatibleWith: nil)
    static let callSpeakerActive: UIImage? = UIImage(named: "call-speaker-active", in: BundleToken.bundle, compatibleWith: nil)
    static let callSpeakerInactive: UIImage? = UIImage(named: "call-speaker-inactive", in: BundleToken.bundle, compatibleWith: nil)
    static let callVideoActive: UIImage? = UIImage(named: "call-video-active", in: BundleToken.bundle, compatibleWith: nil)
    static let callVideoInactive: UIImage? = UIImage(named: "call-video-inactive", in: BundleToken.bundle, compatibleWith: nil)
    static let uploadError: UIImage? = UIImage(named: "uploadError", in: BundleToken.bundle, compatibleWith: nil)
    static let uploadRemove: UIImage? = UIImage(named: "uploadRemove", in: BundleToken.bundle, compatibleWith: nil)
    static let chatPickMedia: UIImage? = UIImage(named: "chatPickMedia", in: BundleToken.bundle, compatibleWith: nil)
    static let chatSend: UIImage? = UIImage(named: "chatSend", in: BundleToken.bundle, compatibleWith: nil)
    static let unreadMessageIndicator: UIImage? = UIImage(named: "unreadMessageIndicator", in: BundleToken.bundle, compatibleWith: nil)
    static let back: UIImage? = UIImage(named: "back", in: BundleToken.bundle, compatibleWith: nil)
    static let close: UIImage? = UIImage(named: "close", in: BundleToken.bundle, compatibleWith: nil)
    static let browseIcon: UIImage? = UIImage(named: "browseIcon", in: BundleToken.bundle, compatibleWith: nil)
    static let cameraIcon: UIImage? = UIImage(named: "cameraIcon", in: BundleToken.bundle, compatibleWith: nil)
    static let photoLibraryIcon: UIImage? = UIImage(named: "photoLibraryIcon", in: BundleToken.bundle, compatibleWith: nil)
    static let gliaLogo: UIImage? = UIImage(named: "gliaLogo", in: BundleToken.bundle, compatibleWith: nil)
    static let startScreenShare: UIImage? = UIImage(named: "startScreenShare", in: BundleToken.bundle, compatibleWith: nil)
    static let upgradeAudio: UIImage? = UIImage(named: "upgradeAudio", in: BundleToken.bundle, compatibleWith: nil)
    static let upgradePhone: UIImage? = UIImage(named: "upgradePhone", in: BundleToken.bundle, compatibleWith: nil)
    static let upgradeVideo: UIImage? = UIImage(named: "upgradeVideo", in: BundleToken.bundle, compatibleWith: nil)
    static let operatorPlaceholder: UIImage? = UIImage(named: "operatorPlaceholder", in: BundleToken.bundle, compatibleWith: nil)
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
