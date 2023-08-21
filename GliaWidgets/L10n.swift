// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces

@available(*, deprecated)
public enum L10n {
  /// This action is not currently supported on mobile
  public static let gvaNotSupported = L10n.tr("Deprecated", "gva.error_unsupported", fallback: "This action is not currently supported on mobile")
  /// Operator
  public static let `operator` = L10n.tr("Deprecated", "operator", fallback: "Operator")
  /// Powered by
  public static let poweredBy = L10n.tr("Deprecated", "poweredBy", fallback: "Powered by")
  public enum Alert {
    public enum Accessibility {
      public enum Action {
        /// Accept
        public static let accept = L10n.tr("Deprecated", "alert.accessibility.action.accept", fallback: "Accept")
        /// Cancel
        public static let cancel = L10n.tr("Deprecated", "alert.accessibility.action.cancel", fallback: "Cancel")
        /// Decline
        public static let decline = L10n.tr("Deprecated", "alert.accessibility.action.decline", fallback: "Decline")
        /// No
        public static let no = L10n.tr("Deprecated", "alert.accessibility.action.no", fallback: "No")
        /// OK
        public static let ok = L10n.tr("Deprecated", "alert.accessibility.action.ok", fallback: "OK")
        /// Settings
        public static let settings = L10n.tr("Deprecated", "alert.accessibility.action.settings", fallback: "Settings")
        /// Yes
        public static let yes = L10n.tr("Deprecated", "alert.accessibility.action.yes", fallback: "Yes")
      }
    }
    public enum Action {
      /// Accept
      public static let accept = L10n.tr("Deprecated", "alert.action.accept", fallback: "Accept")
      /// Cancel
      public static let cancel = L10n.tr("Deprecated", "alert.action.cancel", fallback: "Cancel")
      /// Decline
      public static let decline = L10n.tr("Deprecated", "alert.action.decline", fallback: "Decline")
      /// No
      public static let no = L10n.tr("Deprecated", "alert.action.no", fallback: "No")
      /// OK
      public static let ok = L10n.tr("Deprecated", "alert.action.ok", fallback: "OK")
      /// Settings
      public static let settings = L10n.tr("Deprecated", "alert.action.settings", fallback: "Settings")
      /// Yes
      public static let yes = L10n.tr("Deprecated", "alert.action.yes", fallback: "Yes")
    }
    public enum ApiError {
      /// {message}
      public static let message = L10n.tr("Deprecated", "alert.apiError.message", fallback: "{message}")
      /// We're sorry, there has been an error.
      public static let title = L10n.tr("Deprecated", "alert.apiError.title", fallback: "We're sorry, there has been an error.")
    }
    public enum AudioUpgrade {
      /// {operatorName} has offered you to upgrade to audio
      public static let title = L10n.tr("Deprecated", "alert.audioUpgrade.title", fallback: "{operatorName} has offered you to upgrade to audio")
    }
    public enum CameraPermission {
      /// Allow access to your camera from device menu: “Settings” - “Privacy” - “Camera”
      public static let message = L10n.tr("Deprecated", "alert.cameraPermission.message", fallback: "Allow access to your camera from device menu: “Settings” - “Privacy” - “Camera”")
      /// Unable to access camera
      public static let title = L10n.tr("Deprecated", "alert.cameraPermission.title", fallback: "Unable to access camera")
    }
    public enum EndEngagement {
      /// Are you sure you want to end engagement?
      public static let message = L10n.tr("Deprecated", "alert.endEngagement.message", fallback: "Are you sure you want to end engagement?")
      /// End Engagement?
      public static let title = L10n.tr("Deprecated", "alert.endEngagement.title", fallback: "End Engagement?")
    }
    public enum LeaveQueue {
      /// You will lose your place in the queue.
      public static let message = L10n.tr("Deprecated", "alert.leaveQueue.message", fallback: "You will lose your place in the queue.")
      /// Are you sure you want to leave?
      public static let title = L10n.tr("Deprecated", "alert.leaveQueue.title", fallback: "Are you sure you want to leave?")
    }
    public enum MediaSourceNotAvailable {
      /// This media source is not available on your device
      public static let message = L10n.tr("Deprecated", "alert.mediaSourceNotAvailable.message", fallback: "This media source is not available on your device")
      /// Unable to access media source
      public static let title = L10n.tr("Deprecated", "alert.mediaSourceNotAvailable.title", fallback: "Unable to access media source")
    }
    public enum MediaUpgrade {
      /// {operatorName} has offered you to upgrade
      public static let title = L10n.tr("Deprecated", "alert.mediaUpgrade.title", fallback: "{operatorName} has offered you to upgrade")
      public enum Audio {
        /// Speak through your device
        public static let info = L10n.tr("Deprecated", "alert.mediaUpgrade.audio.info", fallback: "Speak through your device")
        /// Audio
        public static let title = L10n.tr("Deprecated", "alert.mediaUpgrade.audio.title", fallback: "Audio")
      }
      public enum Phone {
        /// Enter your number and we'll call you
        public static let info = L10n.tr("Deprecated", "alert.mediaUpgrade.phone.info", fallback: "Enter your number and we'll call you")
        /// Phone
        public static let title = L10n.tr("Deprecated", "alert.mediaUpgrade.phone.title", fallback: "Phone")
      }
    }
    public enum MicrophonePermission {
      /// Allow access to your microphone from device menu: “Settings” - “Privacy” - “Microphone”
      public static let message = L10n.tr("Deprecated", "alert.microphonePermission.message", fallback: "Allow access to your microphone from device menu: “Settings” - “Privacy” - “Microphone”")
      /// Unable to access microphone
      public static let title = L10n.tr("Deprecated", "alert.microphonePermission.title", fallback: "Unable to access microphone")
    }
    public enum OperatorEndedEngagement {
      /// This engagement has ended.
      /// Thank you!
      public static let message = L10n.tr("Deprecated", "alert.operatorEndedEngagement.message", fallback: "This engagement has ended.\nThank you!")
      /// Engagement Ended
      public static let title = L10n.tr("Deprecated", "alert.operatorEndedEngagement.title", fallback: "Engagement Ended")
    }
    public enum OperatorsUnavailable {
      /// Operators are no longer available.
      /// Please try again later.
      public static let message = L10n.tr("Deprecated", "alert.operatorsUnavailable.message", fallback: "Operators are no longer available.\nPlease try again later.")
      /// We're sorry
      public static let title = L10n.tr("Deprecated", "alert.operatorsUnavailable.title", fallback: "We're sorry")
    }
    public enum ScreenSharing {
      public enum Start {
        /// {operatorName} would like to see the screen of your device
        public static let message = L10n.tr("Deprecated", "alert.screenSharing.start.message", fallback: "{operatorName} would like to see the screen of your device")
        /// {operatorName} has asked you to share your screen
        public static let title = L10n.tr("Deprecated", "alert.screenSharing.start.title", fallback: "{operatorName} has asked you to share your screen")
      }
      public enum Stop {
        /// Are you sure you want to stop sharing your screen?
        public static let message = L10n.tr("Deprecated", "alert.screenSharing.stop.message", fallback: "Are you sure you want to stop sharing your screen?")
        /// Stop screen sharing?
        public static let title = L10n.tr("Deprecated", "alert.screenSharing.stop.title", fallback: "Stop screen sharing?")
      }
    }
    public enum UnavailableMessageCenter {
      /// The Message Center is currently unavailable. Please try again later.
      public static let message = L10n.tr("Deprecated", "alert.unavailableMessageCenter.message", fallback: "The Message Center is currently unavailable. Please try again later.")
      /// We could not verify your authentication status.
      public static let notAuthenticatedMessage = L10n.tr("Deprecated", "alert.unavailableMessageCenter.notAuthenticatedMessage", fallback: "We could not verify your authentication status.")
      /// Message Center Unavailable
      public static let title = L10n.tr("Deprecated", "alert.unavailableMessageCenter.title", fallback: "Message Center Unavailable")
    }
    public enum Unexpected {
      /// Please try again later.
      public static let message = L10n.tr("Deprecated", "alert.unexpected.message", fallback: "Please try again later.")
      /// We're sorry, there has been an unexpected error.
      public static let title = L10n.tr("Deprecated", "alert.unexpected.title", fallback: "We're sorry, there has been an unexpected error.")
    }
    public enum VideoUpgrade {
      public enum OneWay {
        /// {operatorName} has offered you to see their video
        public static let title = L10n.tr("Deprecated", "alert.videoUpgrade.oneWay.title", fallback: "{operatorName} has offered you to see their video")
      }
      public enum TwoWay {
        /// {operatorName} has offered you to upgrade to video
        public static let title = L10n.tr("Deprecated", "alert.videoUpgrade.twoWay.title", fallback: "{operatorName} has offered you to upgrade to video")
      }
    }
    public enum VisitorCode {
      /// Your Visitor Code
      public static let title = L10n.tr("Deprecated", "alert.visitorCode.title", fallback: "Your Visitor Code")
    }
  }
  public enum Call {
    /// You can continue browsing and we will connect you automatically.
    public static let bottomText = L10n.tr("Deprecated", "call.bottomText", fallback: "You can continue browsing and we will connect you automatically.")
    /// (By default your video will be off)
    public static let topText = L10n.tr("Deprecated", "call.topText", fallback: "(By default your video will be off)")
    public enum Accessibility {
      public enum Bubble {
        /// Deactivates minimize.
        public static let hint = L10n.tr("Deprecated", "call.accessibility.bubble.hint", fallback: "Deactivates minimize.")
        /// Operator Avatar
        public static let label = L10n.tr("Deprecated", "call.accessibility.bubble.label", fallback: "Operator Avatar")
      }
      public enum Buttons {
        public enum Chat {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Deprecated", "call.accessibility.buttons.chat.titleAndBadgeValue", fallback: "{buttonTitle}, {badgeValue}")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.chat.active.label", fallback: "Selected")
          }
          public enum BadgeValue {
            /// {badgeValue} unread messages
            public static let multipleItems = L10n.tr("Deprecated", "call.accessibility.buttons.chat.badgeValue.multipleItems", fallback: "{badgeValue} unread messages")
            /// {badgeValue} unread message
            public static let singleItem = L10n.tr("Deprecated", "call.accessibility.buttons.chat.badgeValue.singleItem", fallback: "{badgeValue} unread message")
          }
          public enum Inactive {
            ///
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.chat.inactive.label", fallback: "")
          }
        }
        public enum Minimize {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Deprecated", "call.accessibility.buttons.minimize.titleAndBadgeValue", fallback: "{buttonTitle}, {badgeValue}")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.minimize.active.label", fallback: "Selected")
          }
          public enum BadgeValue {
            ///
            public static let multipleItems = L10n.tr("Deprecated", "call.accessibility.buttons.minimize.badgeValue.multipleItems", fallback: "")
            ///
            public static let singleItem = L10n.tr("Deprecated", "call.accessibility.buttons.minimize.badgeValue.singleItem", fallback: "")
          }
          public enum Inactive {
            ///
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.minimize.inactive.label", fallback: "")
          }
        }
        public enum Mute {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Deprecated", "call.accessibility.buttons.mute.titleAndBadgeValue", fallback: "{buttonTitle}, {badgeValue}")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.mute.active.label", fallback: "Selected")
          }
          public enum BadgeValue {
            ///
            public static let multipleItems = L10n.tr("Deprecated", "call.accessibility.buttons.mute.badgeValue.multipleItems", fallback: "")
            ///
            public static let singleItem = L10n.tr("Deprecated", "call.accessibility.buttons.mute.badgeValue.singleItem", fallback: "")
          }
          public enum Inactive {
            ///
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.mute.inactive.label", fallback: "")
          }
        }
        public enum Speaker {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Deprecated", "call.accessibility.buttons.speaker.titleAndBadgeValue", fallback: "{buttonTitle}, {badgeValue}")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.speaker.active.label", fallback: "Selected")
          }
          public enum BadgeValue {
            ///
            public static let multipleItems = L10n.tr("Deprecated", "call.accessibility.buttons.speaker.badgeValue.multipleItems", fallback: "")
            ///
            public static let singleItem = L10n.tr("Deprecated", "call.accessibility.buttons.speaker.badgeValue.singleItem", fallback: "")
          }
          public enum Inactive {
            ///
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.speaker.inactive.label", fallback: "")
          }
        }
        public enum Video {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Deprecated", "call.accessibility.buttons.video.titleAndBadgeValue", fallback: "{buttonTitle}, {badgeValue}")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.video.active.label", fallback: "Selected")
          }
          public enum BadgeValue {
            ///
            public static let multipleItems = L10n.tr("Deprecated", "call.accessibility.buttons.video.badgeValue.multipleItems", fallback: "")
            ///
            public static let singleItem = L10n.tr("Deprecated", "call.accessibility.buttons.video.badgeValue.singleItem", fallback: "")
          }
          public enum Inactive {
            ///
            public static let label = L10n.tr("Deprecated", "call.accessibility.buttons.video.inactive.label", fallback: "")
          }
        }
      }
      public enum CallDuration {
        /// Displays call duration.
        public static let hint = L10n.tr("Deprecated", "call.accessibility.callDuration.hint", fallback: "Displays call duration.")
      }
      public enum Connect {
        public enum Connected {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Deprecated", "call.accessibility.connect.connected.firstText.hint", fallback: "Displays operator name.")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "call.accessibility.connect.connected.secondText.hint", fallback: "Displays call duration.")
          }
        }
        public enum Connecting {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Deprecated", "call.accessibility.connect.connecting.firstText.hint", fallback: "Displays operator name.")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "call.accessibility.connect.connecting.secondText.hint", fallback: "Displays call duration.")
          }
        }
        public enum Queue {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Deprecated", "call.accessibility.connect.queue.firstText.hint", fallback: "Displays operator name.")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "call.accessibility.connect.queue.secondText.hint", fallback: "Displays call duration.")
          }
        }
      }
      public enum Header {
        public enum BackButton {
          /// Activates minimize.
          public static let hint = L10n.tr("Deprecated", "call.accessibility.header.backButton.hint", fallback: "Activates minimize.")
          /// Back
          public static let label = L10n.tr("Deprecated", "call.accessibility.header.backButton.label", fallback: "Back")
        }
        public enum CloseButton {
          ///
          public static let hint = L10n.tr("Deprecated", "call.accessibility.header.closeButton.hint", fallback: "")
          /// Close
          public static let label = L10n.tr("Deprecated", "call.accessibility.header.closeButton.label", fallback: "Close")
        }
        public enum EndButton {
          /// End
          public static let label = L10n.tr("Deprecated", "call.accessibility.header.endButton.label", fallback: "End")
        }
        public enum EndScreenShareButton {
          ///
          public static let hint = L10n.tr("Deprecated", "call.accessibility.header.endScreenShareButton.hint", fallback: "")
          /// End
          public static let label = L10n.tr("Deprecated", "call.accessibility.header.endScreenShareButton.label", fallback: "End")
        }
      }
      public enum Operator {
        public enum Avatar {
          /// Displays operator avatar or placeholder.
          public static let hint = L10n.tr("Deprecated", "call.accessibility.operator.avatar.hint", fallback: "Displays operator avatar or placeholder.")
          /// Operator Avatar
          public static let label = L10n.tr("Deprecated", "call.accessibility.operator.avatar.label", fallback: "Operator Avatar")
        }
      }
      public enum OperatorName {
        /// Displays operator name.
        public static let hint = L10n.tr("Deprecated", "call.accessibility.operatorName.hint", fallback: "Displays operator name.")
      }
      public enum Video {
        public enum Operator {
          /// Operator's Video
          public static let label = L10n.tr("Deprecated", "call.accessibility.video.operator.label", fallback: "Operator's Video")
        }
        public enum Visitor {
          /// Your Video
          public static let label = L10n.tr("Deprecated", "call.accessibility.video.visitor.label", fallback: "Your Video")
        }
      }
    }
    public enum Audio {
      /// Audio
      public static let title = L10n.tr("Deprecated", "call.audio.title", fallback: "Audio")
    }
    public enum Buttons {
      public enum Chat {
        /// Chat
        public static let title = L10n.tr("Deprecated", "call.buttons.chat.title", fallback: "Chat")
      }
      public enum Minimize {
        /// Minimize
        public static let title = L10n.tr("Deprecated", "call.buttons.minimize.title", fallback: "Minimize")
      }
      public enum Mute {
        public enum Active {
          /// Unmute
          public static let title = L10n.tr("Deprecated", "call.buttons.mute.active.title", fallback: "Unmute")
        }
        public enum Inactive {
          /// Mute
          public static let title = L10n.tr("Deprecated", "call.buttons.mute.inactive.title", fallback: "Mute")
        }
      }
      public enum Speaker {
        /// Speaker
        public static let title = L10n.tr("Deprecated", "call.buttons.speaker.title", fallback: "Speaker")
      }
      public enum Video {
        /// Video
        public static let title = L10n.tr("Deprecated", "call.buttons.video.title", fallback: "Video")
      }
    }
    public enum Connect {
      public enum Connected {
        /// {operatorName}
        public static let firstText = L10n.tr("Deprecated", "call.connect.connected.firstText", fallback: "{operatorName}")
        /// {callDuration}
        public static let secondText = L10n.tr("Deprecated", "call.connect.connected.secondText", fallback: "{callDuration}")
      }
      public enum Connecting {
        /// Connecting with {operatorName}
        public static let firstText = L10n.tr("Deprecated", "call.connect.connecting.firstText", fallback: "Connecting with {operatorName}")
        ///
        public static let secondText = L10n.tr("Deprecated", "call.connect.connecting.secondText", fallback: "")
      }
      public enum Queue {
        /// CompanyName
        public static let firstText = L10n.tr("Deprecated", "call.connect.queue.firstText", fallback: "CompanyName")
        /// We are here to help!
        public static let secondText = L10n.tr("Deprecated", "call.connect.queue.secondText", fallback: "We are here to help!")
      }
      public enum Transferring {
        /// Transferring
        public static let firstText = L10n.tr("Deprecated", "call.connect.transferring.firstText", fallback: "Transferring")
      }
    }
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Deprecated", "call.endButton.title", fallback: "End")
    }
    public enum OnHold {
      /// You can continue browsing while you are on hold
      public static let bottomText = L10n.tr("Deprecated", "call.onHold.bottomText", fallback: "You can continue browsing while you are on hold")
      /// You
      public static let localVideoStreamLabelText = L10n.tr("Deprecated", "call.onHold.localVideoStreamLabelText", fallback: "You")
      /// On Hold
      public static let topText = L10n.tr("Deprecated", "call.onHold.topText", fallback: "On Hold")
    }
    public enum Operator {
      /// {operatorName}
      public static let name = L10n.tr("Deprecated", "call.operator.name", fallback: "{operatorName}")
    }
    public enum Video {
      /// Video
      public static let title = L10n.tr("Deprecated", "call.video.title", fallback: "Video")
    }
  }
  public enum CallVisualizer {
    public enum ScreenSharing {
      /// Your Screen is Being Shared
      public static let message = L10n.tr("Deprecated", "callVisualizer.screenSharing.message", fallback: "Your Screen is Being Shared")
      /// Screen Sharing
      public static let title = L10n.tr("Deprecated", "callVisualizer.screenSharing.title", fallback: "Screen Sharing")
      public enum Accessibility {
        /// Ends screen sharing
        public static let buttonHint = L10n.tr("Deprecated", "callVisualizer.screenSharing.accessibility.buttonHint", fallback: "Ends screen sharing")
        /// End screen sharing
        public static let buttonLabel = L10n.tr("Deprecated", "callVisualizer.screenSharing.accessibility.buttonLabel", fallback: "End screen sharing")
        /// Message label
        public static let messageHint = L10n.tr("Deprecated", "callVisualizer.screenSharing.accessibility.messageHint", fallback: "Message label")
      }
      public enum Button {
        /// End Screen Sharing
        public static let title = L10n.tr("Deprecated", "callVisualizer.screenSharing.button.title", fallback: "End Screen Sharing")
      }
    }
    public enum VisitorCode {
      public enum Accessibility {
        /// Closes visitor code
        public static let closeHint = L10n.tr("Deprecated", "callVisualizer.visitorCode.accessibility.closeHint", fallback: "Closes visitor code")
        /// Close Button
        public static let closeLabel = L10n.tr("Deprecated", "callVisualizer.visitorCode.accessibility.closeLabel", fallback: "Close Button")
        /// Generates new visitor code
        public static let refreshHint = L10n.tr("Deprecated", "callVisualizer.visitorCode.accessibility.refreshHint", fallback: "Generates new visitor code")
        /// Refresh Button
        public static let refreshLabel = L10n.tr("Deprecated", "callVisualizer.visitorCode.accessibility.refreshLabel", fallback: "Refresh Button")
        /// Your five-digit visitor code is
        public static let titleHint = L10n.tr("Deprecated", "callVisualizer.visitorCode.accessibility.titleHint", fallback: "Your five-digit visitor code is")
      }
      public enum Action {
        /// Close
        public static let close = L10n.tr("Deprecated", "callVisualizer.visitorCode.action.close", fallback: "Close")
        /// Refresh
        public static let refresh = L10n.tr("Deprecated", "callVisualizer.visitorCode.action.refresh", fallback: "Refresh")
      }
      public enum Title {
        /// Could not load the visitor code. Please try refreshing.
        public static let error = L10n.tr("Deprecated", "callVisualizer.visitorCode.title.error", fallback: "Could not load the visitor code. Please try refreshing.")
        /// Your Visitor Code
        public static let standard = L10n.tr("Deprecated", "callVisualizer.visitorCode.title.standard", fallback: "Your Visitor Code")
      }
    }
  }
  public enum Chat {
    /// Chat
    public static let title = L10n.tr("Deprecated", "chat.title", fallback: "Chat")
    public enum Accessibility {
      /// You
      public static let visitorName = L10n.tr("Deprecated", "chat.accessibility.visitorName", fallback: "You")
      public enum ChatCallUpgrade {
        public enum Audio {
          public enum Duration {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.chatCallUpgrade.audio.duration.hint", fallback: "Displays call duration.")
          }
        }
        public enum Video {
          public enum Duration {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.chatCallUpgrade.video.duration.hint", fallback: "Displays call duration.")
          }
        }
      }
      public enum Connect {
        public enum Connected {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.connect.connected.firstText.hint", fallback: "Displays operator name.")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.connect.connected.secondText.hint", fallback: "Displays call duration.")
          }
        }
        public enum Connecting {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.connect.connecting.firstText.hint", fallback: "Displays operator name.")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.connect.connecting.secondText.hint", fallback: "Displays call duration.")
          }
        }
        public enum Queue {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.connect.queue.firstText.hint", fallback: "Displays operator name.")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Deprecated", "chat.accessibility.connect.queue.secondText.hint", fallback: "Displays call duration.")
          }
        }
      }
      public enum Download {
        public enum State {
          /// {downloadedFileName}, {downloadedFileState}
          public static let downloaded = L10n.tr("Deprecated", "chat.accessibility.download.state.downloaded", fallback: "{downloadedFileName}, {downloadedFileState}")
          /// {downloadedFileName}, {downloadedFileState} {downloadPercentValue}%%
          public static let downloading = L10n.tr("Deprecated", "chat.accessibility.download.state.downloading", fallback: "{downloadedFileName}, {downloadedFileState} {downloadPercentValue}%%")
          /// {downloadedFileName}, {downloadedFileState}
          public static let error = L10n.tr("Deprecated", "chat.accessibility.download.state.error", fallback: "{downloadedFileName}, {downloadedFileState}")
          /// {downloadedFileName}, {downloadedFileState}
          public static let `none` = L10n.tr("Deprecated", "chat.accessibility.download.state.none", fallback: "{downloadedFileName}, {downloadedFileState}")
        }
      }
      public enum Header {
        public enum BackButton {
          ///
          public static let hint = L10n.tr("Deprecated", "chat.accessibility.header.backButton.hint", fallback: "")
          /// back
          public static let label = L10n.tr("Deprecated", "chat.accessibility.header.backButton.label", fallback: "back")
        }
        public enum CloseButton {
          ///
          public static let hint = L10n.tr("Deprecated", "chat.accessibility.header.closeButton.hint", fallback: "")
          /// Close
          public static let label = L10n.tr("Deprecated", "chat.accessibility.header.closeButton.label", fallback: "Close")
        }
        public enum EndButton {
          /// End
          public static let label = L10n.tr("Deprecated", "chat.accessibility.header.endButton.label", fallback: "End")
        }
        public enum EndScreenShareButton {
          ///
          public static let hint = L10n.tr("Deprecated", "chat.accessibility.header.endScreenShareButton.hint", fallback: "")
          /// End screen share
          public static let label = L10n.tr("Deprecated", "chat.accessibility.header.endScreenShareButton.label", fallback: "End screen share")
        }
      }
      public enum Message {
        /// Attachment from {fileSender}
        public static let attachmentMessageLabel = L10n.tr("Deprecated", "chat.accessibility.message.attachmentMessageLabel", fallback: "Attachment from {fileSender}")
        /// You
        public static let you = L10n.tr("Deprecated", "chat.accessibility.message.you", fallback: "You")
        public enum ChoiceCard {
          public enum ButtonState {
            /// Disabled
            public static let disabled = L10n.tr("Deprecated", "chat.accessibility.message.choiceCard.buttonState.disabled", fallback: "Disabled")
            ///
            public static let normal = L10n.tr("Deprecated", "chat.accessibility.message.choiceCard.buttonState.normal", fallback: "")
            /// Selected
            public static let selected = L10n.tr("Deprecated", "chat.accessibility.message.choiceCard.buttonState.selected", fallback: "Selected")
          }
          public enum Image {
            /// Choice card
            public static let label = L10n.tr("Deprecated", "chat.accessibility.message.choiceCard.image.label", fallback: "Choice card")
          }
        }
        public enum MessageInput {
          /// Message
          public static let label = L10n.tr("Deprecated", "chat.accessibility.message.messageInput.label", fallback: "Message")
        }
        public enum Operator {
          public enum TypingIndicator {
            /// {operatorName} is typing
            public static let label = L10n.tr("Deprecated", "chat.accessibility.message.operator.typingIndicator.label", fallback: "{operatorName} is typing")
          }
        }
        public enum SendButton {
          /// Send
          public static let label = L10n.tr("Deprecated", "chat.accessibility.message.sendButton.label", fallback: "Send")
        }
        public enum UnreadMessagesIndicator {
          /// Unread messages
          public static let label = L10n.tr("Deprecated", "chat.accessibility.message.unreadMessagesIndicator.label", fallback: "Unread messages")
        }
      }
      public enum Operator {
        public enum Avatar {
          /// Displays operator avatar or placeholder.
          public static let hint = L10n.tr("Deprecated", "chat.accessibility.operator.avatar.hint", fallback: "Displays operator avatar or placeholder.")
          /// Avatar
          public static let label = L10n.tr("Deprecated", "chat.accessibility.operator.avatar.label", fallback: "Avatar")
        }
      }
      public enum PickMedia {
        public enum PickAttachmentButton {
          /// Pick attachment
          public static let label = L10n.tr("Deprecated", "chat.accessibility.pickMedia.pickAttachmentButton.label", fallback: "Pick attachment")
        }
      }
      public enum Upload {
        public enum Progress {
          /// {uploadedFileName}, {uploadPercentValue}%%
          public static let fileNameWithProgressValue = L10n.tr("Deprecated", "chat.accessibility.upload.progress.fileNameWithProgressValue", fallback: "{uploadedFileName}, {uploadPercentValue}%%")
          /// {uploadPercentValue}%%
          public static let percentValue = L10n.tr("Deprecated", "chat.accessibility.upload.progress.percentValue", fallback: "{uploadPercentValue}%%")
        }
        public enum RemoveUpload {
          /// Remove upload
          public static let label = L10n.tr("Deprecated", "chat.accessibility.upload.removeUpload.label", fallback: "Remove upload")
        }
      }
    }
    public enum Connect {
      public enum Connected {
        /// {operatorName}
        public static let firstText = L10n.tr("Deprecated", "chat.connect.connected.firstText", fallback: "{operatorName}")
        /// {operatorName} has joined the conversation.
        public static let secondText = L10n.tr("Deprecated", "chat.connect.connected.secondText", fallback: "{operatorName} has joined the conversation.")
      }
      public enum Connecting {
        /// Connecting with {operatorName}
        public static let firstText = L10n.tr("Deprecated", "chat.connect.connecting.firstText", fallback: "Connecting with {operatorName}")
        ///
        public static let secondText = L10n.tr("Deprecated", "chat.connect.connecting.secondText", fallback: "")
      }
      public enum Queue {
        /// CompanyName
        public static let firstText = L10n.tr("Deprecated", "chat.connect.queue.firstText", fallback: "CompanyName")
        /// We are here to help!
        public static let secondText = L10n.tr("Deprecated", "chat.connect.queue.secondText", fallback: "We are here to help!")
      }
      public enum Transferring {
        /// Transferring
        public static let firstText = L10n.tr("Deprecated", "chat.connect.transferring.firstText", fallback: "Transferring")
      }
    }
    public enum Download {
      /// Download
      public static let download = L10n.tr("Deprecated", "chat.download.download", fallback: "Download")
      /// Downloading file…
      public static let downloading = L10n.tr("Deprecated", "chat.download.downloading", fallback: "Downloading file…")
      /// Download failed
      public static let failed = L10n.tr("Deprecated", "chat.download.failed", fallback: "Download failed")
      /// Open
      public static let `open` = L10n.tr("Deprecated", "chat.download.open", fallback: "Open")
      public enum Failed {
        /// Retry
        public static let retry = L10n.tr("Deprecated", "chat.download.failed.retry", fallback: "Retry")
        ///  |
        public static let separator = L10n.tr("Deprecated", "chat.download.failed.separator", fallback: " | ")
      }
    }
    public enum EndButton {
      /// End
      public static let title = L10n.tr("Deprecated", "chat.endButton.title", fallback: "End")
    }
    public enum File {
      public enum Upload {
        /// Checking safety of the file…
        public static let scanning = L10n.tr("Deprecated", "chat.file.upload.scanning", fallback: "Checking safety of the file…")
      }
    }
    public enum Input {
      /// Send
      public static let send = L10n.tr("Deprecated", "chat.input.send", fallback: "Send")
    }
    public enum Message {
      /// Tap on the answer above
      public static let choiceCardPlaceholder = L10n.tr("Deprecated", "chat.message.choiceCardPlaceholder", fallback: "Tap on the answer above")
      /// Enter Message
      public static let enterMessagePlaceholder = L10n.tr("Deprecated", "chat.message.enterMessagePlaceholder", fallback: "Enter Message")
      /// Send a message to start chatting
      public static let startEngagementPlaceholder = L10n.tr("Deprecated", "chat.message.startEngagementPlaceholder", fallback: "Send a message to start chatting")
      public enum Status {
        /// Delivered
        public static let delivered = L10n.tr("Deprecated", "chat.message.status.delivered", fallback: "Delivered")
      }
    }
    public enum PickMedia {
      /// Browse
      public static let browse = L10n.tr("Deprecated", "chat.pickMedia.browse", fallback: "Browse")
      /// Photo Library
      public static let photo = L10n.tr("Deprecated", "chat.pickMedia.photo", fallback: "Photo Library")
      /// Take Photo or Video
      public static let takePhoto = L10n.tr("Deprecated", "chat.pickMedia.takePhoto", fallback: "Take Photo or Video")
    }
    public enum SecureTranscript {
      /// Messaging
      public static let headerTitle = L10n.tr("Deprecated", "chat.secureTranscript.headerTitle", fallback: "Messaging")
      /// New Messages
      public static let unreadMessageDividerTitle = L10n.tr("Deprecated", "chat.secureTranscript.unreadMessageDividerTitle", fallback: "New Messages")
    }
    public enum Status {
      /// Operator typing
      public static let typing = L10n.tr("Deprecated", "chat.status.typing", fallback: "Operator typing")
    }
    public enum Upgrade {
      public enum Audio {
        /// Upgraded to Audio Call
        public static let text = L10n.tr("Deprecated", "chat.upgrade.audio.text", fallback: "Upgraded to Audio Call")
      }
      public enum Video {
        /// Upgraded to Video Call
        public static let text = L10n.tr("Deprecated", "chat.upgrade.video.text", fallback: "Upgraded to Video Call")
      }
    }
    public enum Upload {
      /// Uploading failed
      public static let failed = L10n.tr("Deprecated", "chat.upload.failed", fallback: "Uploading failed")
      /// Ready to send
      public static let uploaded = L10n.tr("Deprecated", "chat.upload.uploaded", fallback: "Ready to send")
      /// Uploading file…
      public static let uploading = L10n.tr("Deprecated", "chat.upload.uploading", fallback: "Uploading file…")
      public enum Error {
        /// File size over 25MB limit!
        public static let fileTooBig = L10n.tr("Deprecated", "chat.upload.error.fileTooBig", fallback: "File size over 25MB limit!")
        /// Failed to upload.
        public static let generic = L10n.tr("Deprecated", "chat.upload.error.generic", fallback: "Failed to upload.")
        /// Network error.
        public static let network = L10n.tr("Deprecated", "chat.upload.error.network", fallback: "Network error.")
        /// Failed to confirm the safety of the file.
        public static let safetyCheckFailed = L10n.tr("Deprecated", "chat.upload.error.safetyCheckFailed", fallback: "Failed to confirm the safety of the file.")
        /// Invalid file type!
        public static let unsupportedFileType = L10n.tr("Deprecated", "chat.upload.error.unsupportedFileType", fallback: "Invalid file type!")
      }
    }
  }
  public enum MessageCenter {
    public enum Confirmation {
      /// Check messages
      public static let checkMessages = L10n.tr("Deprecated", "messageCenter.confirmation.checkMessages", fallback: "Check messages")
      /// Messaging
      public static let header = L10n.tr("Deprecated", "messageCenter.confirmation.header", fallback: "Messaging")
      /// Your message has been sent. We will get back to you within 48 hours.
      public static let subtitle = L10n.tr("Deprecated", "messageCenter.confirmation.subtitle", fallback: "Your message has been sent. We will get back to you within 48 hours.")
      /// Thank you!
      public static let title = L10n.tr("Deprecated", "messageCenter.confirmation.title", fallback: "Thank you!")
      public enum Accessibility {
        /// Navigates you to the chat transcript.
        public static let checkMessagesHint = L10n.tr("Deprecated", "messageCenter.confirmation.accessibility.checkMessagesHint", fallback: "Navigates you to the chat transcript.")
        /// Check messages
        public static let checkMessagesLabel = L10n.tr("Deprecated", "messageCenter.confirmation.accessibility.checkMessagesLabel", fallback: "Check messages")
      }
    }
    public enum Welcome {
      /// Check messages
      public static let checkMessages = L10n.tr("Deprecated", "messageCenter.welcome.checkMessages", fallback: "Check messages")
      /// Messaging
      public static let header = L10n.tr("Deprecated", "messageCenter.welcome.header", fallback: "Messaging")
      /// The message cannot exceed 10000 characters.
      public static let messageLengthWarning = L10n.tr("Deprecated", "messageCenter.welcome.messageLengthWarning", fallback: "The message cannot exceed 10000 characters.")
      /// Enter your message
      public static let messageTextViewActive = L10n.tr("Deprecated", "messageCenter.welcome.messageTextViewActive", fallback: "Enter your message")
      /// Enter your message
      public static let messageTextViewDisabled = L10n.tr("Deprecated", "messageCenter.welcome.messageTextViewDisabled", fallback: "Enter your message")
      /// Enter your message
      public static let messageTextViewNormal = L10n.tr("Deprecated", "messageCenter.welcome.messageTextViewNormal", fallback: "Enter your message")
      /// Your message
      public static let messageTitle = L10n.tr("Deprecated", "messageCenter.welcome.messageTitle", fallback: "Your message")
      /// Send
      public static let sendDisabled = L10n.tr("Deprecated", "messageCenter.welcome.sendDisabled", fallback: "Send")
      /// Send
      public static let sendEnabled = L10n.tr("Deprecated", "messageCenter.welcome.sendEnabled", fallback: "Send")
      /// Send
      public static let sendLoading = L10n.tr("Deprecated", "messageCenter.welcome.sendLoading", fallback: "Send")
      /// Send a message and we’ll get back to you within 48 hours
      public static let subtitle = L10n.tr("Deprecated", "messageCenter.welcome.subtitle", fallback: "Send a message and we’ll get back to you within 48 hours")
      /// Welcome to Message Center
      public static let title = L10n.tr("Deprecated", "messageCenter.welcome.title", fallback: "Welcome to Message Center")
      public enum Accessibility {
        /// Navigates you to the chat transcript.
        public static let checkMessagesHint = L10n.tr("Deprecated", "messageCenter.welcome.accessibility.checkMessagesHint", fallback: "Navigates you to the chat transcript.")
        /// Check messages
        public static let checkMessagesLabel = L10n.tr("Deprecated", "messageCenter.welcome.accessibility.checkMessagesLabel", fallback: "Check messages")
        /// Opens the file picker to attach media.
        public static let filePickerHint = L10n.tr("Deprecated", "messageCenter.welcome.accessibility.filePickerHint", fallback: "Opens the file picker to attach media.")
        /// File picker
        public static let filePickerLabel = L10n.tr("Deprecated", "messageCenter.welcome.accessibility.filePickerLabel", fallback: "File picker")
        /// Sends a secure message.
        public static let sendHint = L10n.tr("Deprecated", "messageCenter.welcome.accessibility.sendHint", fallback: "Sends a secure message.")
        /// Send
        public static let sendLabel = L10n.tr("Deprecated", "messageCenter.welcome.accessibility.sendLabel", fallback: "Send")
      }
    }
  }
  public enum Screensharing {
    public enum VisitorScreen {
      public enum Disclaimer {
        /// Depending on your selection, your entire screen might be shared with the operator, not just the application window.
        public static let info = L10n.tr("Deprecated", "screensharing.visitor_screen.disclaimer.info", fallback: "Depending on your selection, your entire screen might be shared with the operator, not just the application window.")
      }
    }
  }
  public enum SendMessage {
    /// Send message
    public static let send = L10n.tr("Deprecated", "send_message.send", fallback: "Send message")
    /// Sending…
    public static let sending = L10n.tr("Deprecated", "send_message.sending", fallback: "Sending…")
  }
  public enum Survey {
    public enum Accessibility {
      public enum Footer {
        public enum CancelButton {
          /// Cancel
          public static let label = L10n.tr("Deprecated", "survey.accessibility.footer.cancelButton.label", fallback: "Cancel")
        }
        public enum SubmitButton {
          /// Submit
          public static let label = L10n.tr("Deprecated", "survey.accessibility.footer.submitButton.label", fallback: "Submit")
        }
      }
      public enum Question {
        public enum OptionButton {
          public enum Selected {
            /// Selected: {buttonTitle}
            public static let label = L10n.tr("Deprecated", "survey.accessibility.question.optionButton.selected.label", fallback: "Selected: {buttonTitle}")
          }
          public enum Unselected {
            /// Unselected: {buttonTitle}
            public static let label = L10n.tr("Deprecated", "survey.accessibility.question.optionButton.unselected.label", fallback: "Unselected: {buttonTitle}")
          }
        }
        public enum TextField {
          /// Enter the answer
          public static let hint = L10n.tr("Deprecated", "survey.accessibility.question.textField.hint", fallback: "Enter the answer")
        }
        public enum Title {
          /// Required
          public static let value = L10n.tr("Deprecated", "survey.accessibility.question.title.value", fallback: "Required")
        }
      }
      public enum Validation {
        public enum Title {
          /// Please provide an answer for question above
          public static let label = L10n.tr("Deprecated", "survey.accessibility.validation.title.label", fallback: "Please provide an answer for question above")
        }
      }
    }
    public enum Action {
      /// Cancel
      public static let cancel = L10n.tr("Deprecated", "survey.action.cancel", fallback: "Cancel")
      /// No
      public static let no = L10n.tr("Deprecated", "survey.action.no", fallback: "No")
      /// Submit
      public static let submit = L10n.tr("Deprecated", "survey.action.submit", fallback: "Submit")
      /// Please provide an answer.
      public static let validationError = L10n.tr("Deprecated", "survey.action.validationError", fallback: "Please provide an answer.")
      /// Yes
      public static let yes = L10n.tr("Deprecated", "survey.action.yes", fallback: "Yes")
    }
    public enum Question {
      public enum Title {
        /// *
        public static let asterisk = L10n.tr("Deprecated", "survey.question.title.asterisk", fallback: "*")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
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

// swiftlint:enable all
