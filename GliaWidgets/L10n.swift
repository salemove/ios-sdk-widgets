// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// Operator
  public static let `operator` = L10n.tr("Localizable", "operator")
  /// Powered by
  public static let poweredBy = L10n.tr("Localizable", "poweredBy")

  public enum Alert {
    public enum Action {
      /// Accept
      public static let accept = L10n.tr("Localizable", "alert.action.accept")
      /// Cancel
      public static let cancel = L10n.tr("Localizable", "alert.action.cancel")
      /// Decline
      public static let decline = L10n.tr("Localizable", "alert.action.decline")
      /// No
      public static let no = L10n.tr("Localizable", "alert.action.no")
      /// OK
      public static let ok = L10n.tr("Localizable", "alert.action.ok")
      /// Settings
      public static let settings = L10n.tr("Localizable", "alert.action.settings")
      /// Yes
      public static let yes = L10n.tr("Localizable", "alert.action.yes")
    }
    public enum ApiError {
      /// {message}
      public static let message = L10n.tr("Localizable", "alert.apiError.message")
      /// We're sorry, there has been an error.
      public static let title = L10n.tr("Localizable", "alert.apiError.title")
    }
    public enum AudioUpgrade {
      /// {operatorName} has offered you to upgrade to audio
      public static let title = L10n.tr("Localizable", "alert.audioUpgrade.title")
    }
    public enum CameraPermission {
      /// Allow access to your camera from device menu: “Settings” - “Privacy” - “Camera”
      public static let message = L10n.tr("Localizable", "alert.cameraPermission.message")
      /// Unable to access camera
      public static let title = L10n.tr("Localizable", "alert.cameraPermission.title")
    }
    public enum EndEngagement {
      /// Are you sure you want to end engagement?
      public static let message = L10n.tr("Localizable", "alert.endEngagement.message")
      /// End Engagement?
      public static let title = L10n.tr("Localizable", "alert.endEngagement.title")
    }
    public enum LeaveQueue {
      /// You will lose your place in the queue.
      public static let message = L10n.tr("Localizable", "alert.leaveQueue.message")
      /// Are you sure you want to leave?
      public static let title = L10n.tr("Localizable", "alert.leaveQueue.title")
    }
    public enum MediaSourceNotAvailable {
      /// This media source is not available on your device
      public static let message = L10n.tr("Localizable", "alert.mediaSourceNotAvailable.message")
      /// Unable to access media source
      public static let title = L10n.tr("Localizable", "alert.mediaSourceNotAvailable.title")
    }
    public enum MediaUpgrade {
      /// {operatorName} has offered you to upgrade
      public static let title = L10n.tr("Localizable", "alert.mediaUpgrade.title")
      public enum Audio {
        /// Speak through your device
        public static let info = L10n.tr("Localizable", "alert.mediaUpgrade.audio.info")
        /// Audio
        public static let title = L10n.tr("Localizable", "alert.mediaUpgrade.audio.title")
      }
      public enum Phone {
        /// Enter your number and we'll call you
        public static let info = L10n.tr("Localizable", "alert.mediaUpgrade.phone.info")
        /// Phone
        public static let title = L10n.tr("Localizable", "alert.mediaUpgrade.phone.title")
      }
    }
    public enum MicrophonePermission {
      /// Allow access to your microphone from device menu: “Settings” - “Privacy” - “Microphone”
      public static let message = L10n.tr("Localizable", "alert.microphonePermission.message")
      /// Unable to access microphone
      public static let title = L10n.tr("Localizable", "alert.microphonePermission.title")
    }
    public enum OperatorEndedEngagement {
      /// This engagement has ended.
      /// Thank you!
      public static let message = L10n.tr("Localizable", "alert.operatorEndedEngagement.message")
      /// Engagement Ended
      public static let title = L10n.tr("Localizable", "alert.operatorEndedEngagement.title")
    }
    public enum OperatorsUnavailable {
      /// Operators are no longer available.
      /// Please try again later.
      public static let message = L10n.tr("Localizable", "alert.operatorsUnavailable.message")
      /// We’re sorry
      public static let title = L10n.tr("Localizable", "alert.operatorsUnavailable.title")
    }
    public enum ScreenSharing {
      public enum Start {
        /// {operatorName} would like to see the screen of your device
        public static let message = L10n.tr("Localizable", "alert.screenSharing.start.message")
        /// {operatorName} has asked you to share your screen
        public static let title = L10n.tr("Localizable", "alert.screenSharing.start.title")
      }
      public enum Stop {
        /// Are you sure you want to stop sharing your screen?
        public static let message = L10n.tr("Localizable", "alert.screenSharing.stop.message")
        /// Stop screen sharing?
        public static let title = L10n.tr("Localizable", "alert.screenSharing.stop.title")
      }
    }
    public enum Unexpected {
      /// Please try again later.
      public static let message = L10n.tr("Localizable", "alert.unexpected.message")
      /// We're sorry, there has been an unexpected error.
      public static let title = L10n.tr("Localizable", "alert.unexpected.title")
    }
    public enum VideoUpgrade {
      public enum OneWay {
        /// {operatorName} has offered you to see their video
        public static let title = L10n.tr("Localizable", "alert.videoUpgrade.oneWay.title")
      }
      public enum TwoWay {
        /// {operatorName} has offered you to upgrade to video
        public static let title = L10n.tr("Localizable", "alert.videoUpgrade.twoWay.title")
      }
    }
  }

  public enum Call {
    /// You can continue browsing and we’ll connect you automatically.
    public static let bottomText = L10n.tr("Localizable", "call.bottomText")
    /// (By default your video will be off)
    public static let topText = L10n.tr("Localizable", "call.topText")
    public enum Audio {
      /// Audio
      public static let title = L10n.tr("Localizable", "call.audio.title")
    }
    public enum Buttons {
      public enum Chat {
        /// Chat
        public static let title = L10n.tr("Localizable", "call.buttons.chat.title")
      }
      public enum Minimize {
        /// Minimize
        public static let title = L10n.tr("Localizable", "call.buttons.minimize.title")
      }
      public enum Mute {
        public enum Active {
          /// Unmute
          public static let title = L10n.tr("Localizable", "call.buttons.mute.active.title")
        }
        public enum Inactive {
          /// Mute
          public static let title = L10n.tr("Localizable", "call.buttons.mute.inactive.title")
        }
      }
      public enum Speaker {
        /// Speaker
        public static let title = L10n.tr("Localizable", "call.buttons.speaker.title")
      }
      public enum Video {
        /// Video
        public static let title = L10n.tr("Localizable", "call.buttons.video.title")
      }
    }
    public enum Connect {
      public enum Connected {
        /// {operatorName}
        public static let firstText = L10n.tr("Localizable", "call.connect.connected.firstText")
        /// {callDuration}
        public static let secondText = L10n.tr("Localizable", "call.connect.connected.secondText")
      }
      public enum Connecting {
        /// Connecting with {operatorName}
        public static let firstText = L10n.tr("Localizable", "call.connect.connecting.firstText")
        /// 
        public static let secondText = L10n.tr("Localizable", "call.connect.connecting.secondText")
      }
      public enum Queue {
        /// CompanyName
        public static let firstText = L10n.tr("Localizable", "call.connect.queue.firstText")
        /// An MSR will be with you shortly.
        public static let secondText = L10n.tr("Localizable", "call.connect.queue.secondText")
      }
      public enum Transferring {
        /// Transferring
        public static let firstText = L10n.tr("Localizable", "call.connect.transferring.firstText")
      }
    }
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Localizable", "call.endButton.title")
    }
    public enum OnHold {
      /// You can continue browsing while you are on hold
      public static let bottomText = L10n.tr("Localizable", "call.onHold.bottomText")
      /// You
      public static let localVideoStreamLabelText = L10n.tr("Localizable", "call.onHold.localVideoStreamLabelText")
      /// On Hold
      public static let topText = L10n.tr("Localizable", "call.onHold.topText")
    }
    public enum Operator {
      /// {operatorName}
      public static let name = L10n.tr("Localizable", "call.operator.name")
    }
    public enum Video {
      /// Video
      public static let title = L10n.tr("Localizable", "call.video.title")
    }
  }

  public enum Chat {
    /// Chat
    public static let title = L10n.tr("Localizable", "chat.title")
    public enum Connect {
      public enum Connected {
        /// {operatorName}
        public static let firstText = L10n.tr("Localizable", "chat.connect.connected.firstText")
        /// {operatorName} has joined the conversation.
        public static let secondText = L10n.tr("Localizable", "chat.connect.connected.secondText")
      }
      public enum Connecting {
        /// Connecting with {operatorName}
        public static let firstText = L10n.tr("Localizable", "chat.connect.connecting.firstText")
        /// 
        public static let secondText = L10n.tr("Localizable", "chat.connect.connecting.secondText")
      }
      public enum Queue {
        /// CompanyName
        public static let firstText = L10n.tr("Localizable", "chat.connect.queue.firstText")
        /// An MSR will be with you shortly.
        public static let secondText = L10n.tr("Localizable", "chat.connect.queue.secondText")
      }
      public enum Transferring {
        /// Transferring
        public static let firstText = L10n.tr("Localizable", "chat.connect.transferring.firstText")
      }
    }
    public enum Download {
      /// Download
      public static let download = L10n.tr("Localizable", "chat.download.download")
      /// Downloading file…
      public static let downloading = L10n.tr("Localizable", "chat.download.downloading")
      /// Download failed
      public static let failed = L10n.tr("Localizable", "chat.download.failed")
      /// Open
      public static let `open` = L10n.tr("Localizable", "chat.download.open")
      public enum Failed {
        /// Retry
        public static let retry = L10n.tr("Localizable", "chat.download.failed.retry")
        ///  | 
        public static let separator = L10n.tr("Localizable", "chat.download.failed.separator")
      }
    }
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Localizable", "chat.endButton.title")
    }
    public enum Message {
      /// Tap on the answer above
      public static let choiceCardPlaceholder = L10n.tr("Localizable", "chat.message.choiceCardPlaceholder")
      /// Enter Message
      public static let enterMessagePlaceholder = L10n.tr("Localizable", "chat.message.enterMessagePlaceholder")
      /// Send a message to start chatting
      public static let startEngagementPlaceholder = L10n.tr("Localizable", "chat.message.startEngagementPlaceholder")
      public enum Status {
        /// Delivered
        public static let delivered = L10n.tr("Localizable", "chat.message.status.delivered")
      }
    }
    public enum PickMedia {
      /// Browse
      public static let browse = L10n.tr("Localizable", "chat.pickMedia.browse")
      /// Photo Library
      public static let photo = L10n.tr("Localizable", "chat.pickMedia.photo")
      /// Take Photo or Video
      public static let takePhoto = L10n.tr("Localizable", "chat.pickMedia.takePhoto")
    }
    public enum Upgrade {
      public enum Audio {
        /// Upgraded to Audio Call
        public static let text = L10n.tr("Localizable", "chat.upgrade.audio.text")
      }
      public enum Video {
        /// Upgraded to Video Call
        public static let text = L10n.tr("Localizable", "chat.upgrade.video.text")
      }
    }
    public enum Upload {
      /// Uploading failed
      public static let failed = L10n.tr("Localizable", "chat.upload.failed")
      /// Ready to send
      public static let uploaded = L10n.tr("Localizable", "chat.upload.uploaded")
      /// Uploading file…
      public static let uploading = L10n.tr("Localizable", "chat.upload.uploading")
      public enum Error {
        /// File size over 25mb limit!
        public static let fileTooBig = L10n.tr("Localizable", "chat.upload.error.fileTooBig")
        /// Failed to upload.
        public static let generic = L10n.tr("Localizable", "chat.upload.error.generic")
        /// Network error.
        public static let network = L10n.tr("Localizable", "chat.upload.error.network")
        /// Failed to check the safety of the file.
        public static let safetyCheckFailed = L10n.tr("Localizable", "chat.upload.error.safetyCheckFailed")
        /// Invalid file type!
        public static let unsupportedFileType = L10n.tr("Localizable", "chat.upload.error.unsupportedFileType")
      }
    }
  }

  public enum Survey {
    public enum Action {
      /// Cancel
      public static let cancel = L10n.tr("Localizable", "survey.action.cancel")
      /// No
      public static let no = L10n.tr("Localizable", "survey.action.no")
      /// Submit
      public static let submit = L10n.tr("Localizable", "survey.action.submit")
      /// Please provide an answer.
      public static let validationError = L10n.tr("Localizable", "survey.action.validationError")
      /// Yes
      public static let yes = L10n.tr("Localizable", "survey.action.yes")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
