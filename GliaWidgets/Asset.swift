

private let bundleManaging: BundleManaging = .live

#if os(OSX)
  import AppKit.NSImage
  public typealias AssetColorTypeAlias = NSColor
  public typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  public typealias AssetColorTypeAlias = UIColor
  public typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length


public struct ImageAsset {
  public fileprivate(set) var name: String

  public var image: Image {
    let bundle = bundleManaging.current()
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
        assertionFailure("Unable to load image named \(name).")
        return Image()
    }
    return result
  }
}

public struct ColorAsset {
  public fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  public var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
    public static let alertClose = ImageAsset(name: "alertClose")
      public static let callChat = ImageAsset(name: "call-chat")
      public static let callMiminize = ImageAsset(name: "call-miminize")
      public static let callMuteActive = ImageAsset(name: "call-mute-active")
      public static let callMuteInactive = ImageAsset(name: "call-mute-inactive")
      public static let callSpeakerActive = ImageAsset(name: "call-speaker-active")
      public static let callSpeakerInactive = ImageAsset(name: "call-speaker-inactive")
      public static let callVideoActive = ImageAsset(name: "call-video-active")
      public static let callVideoInactive = ImageAsset(name: "call-video-inactive")
      public static let flipCamera = ImageAsset(name: "flip-camera")
      public static let callOnHold = ImageAsset(name: "call-on-hold")
    public static let screensharing = ImageAsset(name: "screensharing")
      public static let uploadError = ImageAsset(name: "uploadError")
      public static let uploadRemove = ImageAsset(name: "uploadRemove")
    public static let chatPickMedia = ImageAsset(name: "chatPickMedia")
    public static let chatSend = ImageAsset(name: "chatSend")
    public static let sendMessageUnavailableInfo = ImageAsset(name: "send-message-unavailable-info")
    public static let unreadMessageIndicator = ImageAsset(name: "unreadMessageIndicator")
    public static let back = ImageAsset(name: "back")
    public static let close = ImageAsset(name: "close")
    public static let browseIcon = ImageAsset(name: "browseIcon")
    public static let cameraIcon = ImageAsset(name: "cameraIcon")
    public static let chevronDownIcon = ImageAsset(name: "chevronDownIcon")
    public static let photoLibraryIcon = ImageAsset(name: "photoLibraryIcon")
    public static let gliaLogo = ImageAsset(name: "gliaLogo")
    public static let startScreenShare = ImageAsset(name: "startScreenShare")
    public static let upgradeAudio = ImageAsset(name: "upgradeAudio")
    public static let upgradePhone = ImageAsset(name: "upgradePhone")
    public static let upgradeVideo = ImageAsset(name: "upgradeVideo")
      public static let mcRemoveUpload = ImageAsset(name: "mc-remove-upload")
    public static let mcConfirmation = ImageAsset(name: "mc-confirmation")
    public static let mcEnvelope = ImageAsset(name: "mc-envelope")
    public static let mcPickMedia = ImageAsset(name: "mc-pick-media")
    public static let mcWarningIcon = ImageAsset(name: "mc-warning-icon")
    public static let mockImage = ImageAsset(name: "mock-image")
    public static let operatorPlaceholder = ImageAsset(name: "operatorPlaceholder")
    public static let operatorTransferring = ImageAsset(name: "operatorTransferring")
    public static let surveyCheckboxChecked = ImageAsset(name: "survey-checkbox-checked")
    public static let surveyCheckbox = ImageAsset(name: "survey-checkbox")
    public static let surveyValidationError = ImageAsset(name: "survey-validation-error")
    public static let spinner = ImageAsset(name: "spinner")

  // swiftlint:disable trailing_comma
  public static let allColors: [ColorAsset] = [
  ]
  public static let allImages: [ImageAsset] = [
      alertClose,
      callChat,
      callMiminize,
      callMuteActive,
      callMuteInactive,
      callSpeakerActive,
      callSpeakerInactive,
      callVideoActive,
      callVideoInactive,
      flipCamera,
      callOnHold,
      screensharing,
      uploadError,
      uploadRemove,
      chatPickMedia,
      chatSend,
      sendMessageUnavailableInfo,
      unreadMessageIndicator,
      back,
      close,
      browseIcon,
      cameraIcon,
      chevronDownIcon,
      photoLibraryIcon,
      gliaLogo,
      startScreenShare,
      upgradeAudio,
      upgradePhone,
      upgradeVideo,
      mcRemoveUpload,
      mcConfirmation,
      mcEnvelope,
      mcPickMedia,
      mcWarningIcon,
      mockImage,
      operatorPlaceholder,
      operatorTransferring,
      surveyCheckboxChecked,
      surveyCheckbox,
      surveyValidationError,
      spinner,
    ]
    // swiftlint:enable trailing_comma
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

public extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = bundleManaging.current()
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}
