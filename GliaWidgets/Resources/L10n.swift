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
      /// Allow access to you micrphone from device menu: “Settings” - “Privacy” - “Camera”
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
      /// Allow access to you micrphone from device menu: “Settings” - “Privacy” - “Microphone”
      public static let message = L10n.tr("Localizable", "alert.microphonePermission.message")
      /// Unable to access microphone
      public static let title = L10n.tr("Localizable", "alert.microphonePermission.title")
    }
    public enum OperatorsUnavailable {
      /// Operators are no longer available.\nPlease try again later.
      public static let message = L10n.tr("Localizable", "alert.operatorsUnavailable.message")
      /// We’re sorry
      public static let title = L10n.tr("Localizable", "alert.operatorsUnavailable.title")
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
      /// AUDIO CALL
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
    }
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Localizable", "call.endButton.title")
    }
    public enum Operator {
      /// {operatorName}
      public static let name = L10n.tr("Localizable", "call.operator.name")
    }
    public enum Video {
      /// VIDEO CALL
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
    }
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Localizable", "chat.endButton.title")
    }
    public enum Message {
      /// Enter Message
      public static let placeholder = L10n.tr("Localizable", "chat.message.placeholder")
      public enum Status {
        /// Delivered
        public static let delivered = L10n.tr("Localizable", "chat.message.status.delivered")
      }
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
