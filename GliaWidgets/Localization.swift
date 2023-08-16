// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localization {
  internal enum Alert {
    internal enum Action {
      /// Settings
      internal static let settings = Localization.tr("Localizable", "alert.action.settings", fallback: "Settings")
    }
  }
  internal enum Call {
    /// On Hold
    internal static let onHold = Localization.tr("Localizable", "call.on_hold", fallback: "On Hold")
    internal enum Bubble {
      internal enum Accessibility {
        /// Deactivates minimize.
        internal static let hint = Localization.tr("Localizable", "call.bubble.accessibility.hint", fallback: "Deactivates minimize.")
        /// Operator Avatar
        internal static let label = Localization.tr("Localizable", "call.bubble.accessibility.label", fallback: "Operator Avatar")
      }
    }
    internal enum Button {
      /// Mute
      internal static let mute = Localization.tr("Localizable", "call.button.mute", fallback: "Mute")
      /// Speaker
      internal static let speaker = Localization.tr("Localizable", "call.button.speaker", fallback: "Speaker")
      /// Unmute
      internal static let unmute = Localization.tr("Localizable", "call.button.unmute", fallback: "Unmute")
    }
    internal enum Buttons {
      internal enum Chat {
        internal enum BadgeValue {
          internal enum MultipleItems {
            internal enum Accessibility {
              /// {badgeValue} unread messages
              internal static let label = Localization.tr("Localizable", "call.buttons.chat.badge_value.multiple_items.accessibility.label", fallback: "{badgeValue} unread messages")
            }
          }
          internal enum SingleItem {
            internal enum Accessibility {
              /// {badgeValue} unread message
              internal static let label = Localization.tr("Localizable", "call.buttons.chat.badge_value.single_item.accessibility.label", fallback: "{badgeValue} unread message")
            }
          }
        }
      }
    }
    internal enum Connect {
      internal enum FirstText {
        internal enum Accessibility {
          /// Displays operator name.
          internal static let hint = Localization.tr("Localizable", "call.connect.first_text.accessibility.hint", fallback: "Displays operator name.")
        }
      }
      internal enum SecondText {
        internal enum Accessibility {
          /// Displays call duration.
          internal static let hint = Localization.tr("Localizable", "call.connect.second_text.accessibility.hint", fallback: "Displays call duration.")
        }
      }
    }
    internal enum Header {
      internal enum Close {
        internal enum Button {
          internal enum Accessibility {
            /// Activates minimize.
            internal static let hint = Localization.tr("Localizable", "call.header.close.button.accessibility.hint", fallback: "Activates minimize.")
          }
        }
      }
    }
    internal enum OnHold {
      /// You can continue browsing while you are on hold
      internal static let bottomText = Localization.tr("Localizable", "call.onHold.bottom_text", fallback: "You can continue browsing while you are on hold")
    }
    internal enum Operator {
      internal enum Avatar {
        internal enum Accessibility {
          /// Displays operator avatar or placeholder.
          internal static let hint = Localization.tr("Localizable", "call.operator.avatar.accessibility.hint", fallback: "Displays operator avatar or placeholder.")
          /// Operator Avatar
          internal static let label = Localization.tr("Localizable", "call.operator.avatar.accessibility.label", fallback: "Operator Avatar")
        }
      }
    }
    internal enum OperatorName {
      internal enum Accessibility {
        /// Displays operator name.
        internal static let hint = Localization.tr("Localizable", "call.operator_name.accessibility.hint", fallback: "Displays operator name.")
      }
    }
    internal enum Video {
      internal enum Operator {
        internal enum Accessibility {
          /// Operator's Video
          internal static let label = Localization.tr("Localizable", "call.video.operator.accessibility.label", fallback: "Operator's Video")
        }
      }
      internal enum Visitor {
        internal enum Accessibility {
          /// Your Video
          internal static let label = Localization.tr("Localizable", "call.video.visitor.accessibility.label", fallback: "Your Video")
        }
      }
    }
  }
  internal enum CallVisualizer {
    internal enum ScreenSharing {
      /// Your Screen is Being Shared
      internal static let message = Localization.tr("Localizable", "call_visualizer.screen_sharing.message", fallback: "Your Screen is Being Shared")
      /// Screen Sharing
      internal static let title = Localization.tr("Localizable", "call_visualizer.screen_sharing.title", fallback: "Screen Sharing")
    }
    internal enum VisitorCode {
      /// Your Visitor Code
      internal static let title = Localization.tr("Localizable", "call_visualizer.visitor_code.title", fallback: "Your Visitor Code")
      internal enum Action {
        /// Close
        internal static let close = Localization.tr("Localizable", "call_visualizer.visitor_code.action.close", fallback: "Close")
        /// Refresh
        internal static let refresh = Localization.tr("Localizable", "call_visualizer.visitor_code.action.refresh", fallback: "Refresh")
      }
      internal enum Close {
        internal enum Accessibility {
          /// Closes visitor code
          internal static let hint = Localization.tr("Localizable", "call_visualizer.visitor_code.close.accessibility.hint", fallback: "Closes visitor code")
          /// Close Button
          internal static let label = Localization.tr("Localizable", "call_visualizer.visitor_code.close.accessibility.label", fallback: "Close Button")
        }
      }
      internal enum Refresh {
        internal enum Accessibility {
          /// Generates new visitor code
          internal static let hint = Localization.tr("Localizable", "call_visualizer.visitor_code.refresh.accessibility.hint", fallback: "Generates new visitor code")
          /// Refresh Button
          internal static let label = Localization.tr("Localizable", "call_visualizer.visitor_code.refresh.accessibility.label", fallback: "Refresh Button")
        }
      }
      internal enum Title {
        internal enum Accessibility {
          /// Your five-digit visitor code is
          internal static let hint = Localization.tr("Localizable", "call_visualizer.visitor_code.title.accessibility.hint", fallback: "Your five-digit visitor code is")
        }
      }
    }
  }
  internal enum Chat {
    /// Pick attachment
    internal static let attachFiles = Localization.tr("Localizable", "chat.attach_files", fallback: "Pick attachment")
    /// {operatorName} has joined the conversation.
    internal static let operatorJoined = Localization.tr("Localizable", "chat.operator_joined", fallback: "{operatorName} has joined the conversation.")
    /// New Messages
    internal static let unreadMessageDivider = Localization.tr("Localizable", "chat.unread_message_divider", fallback: "New Messages")
    internal enum Attachement {
      /// Photo Library
      internal static let photoLibrary = Localization.tr("Localizable", "chat.attachement.photo_library", fallback: "Photo Library")
      /// Take Photo or Video
      internal static let takePhoto = Localization.tr("Localizable", "chat.attachement.take_photo", fallback: "Take Photo or Video")
      internal enum Upload {
        /// Invalid file type!
        internal static let unsupportedFile = Localization.tr("Localizable", "chat.attachement.upload.unsupported_file", fallback: "Invalid file type!")
      }
    }
    internal enum Download {
      /// Downloading file…
      internal static let downloading = Localization.tr("Localizable", "chat.download.downloading", fallback: "Downloading file…")
    }
    internal enum Duration {
      internal enum Accessibility {
        /// Displays call duration.
        internal static let label = Localization.tr("Localizable", "chat.duration.accessibility.label", fallback: "Displays call duration.")
      }
    }
    internal enum File {
      /// Failed to confirm the safety of the file.
      internal static let infectedError = Localization.tr("Localizable", "chat.file.infected_error", fallback: "Failed to confirm the safety of the file.")
      /// File size over 25MB limit!
      internal static let tooLargeError = Localization.tr("Localizable", "chat.file.too_large_error", fallback: "File size over 25MB limit!")
      internal enum Upload {
        /// Uploading failed
        internal static let failed = Localization.tr("Localizable", "chat.file.upload.failed", fallback: "Uploading failed")
        /// Uploading file…
        internal static let inProgress = Localization.tr("Localizable", "chat.file.upload.in_progress", fallback: "Uploading file…")
        /// Checking safety of the file…
        internal static let scanning = Localization.tr("Localizable", "chat.file.upload.scanning", fallback: "Checking safety of the file…")
        /// Ready to send
        internal static let success = Localization.tr("Localizable", "chat.file.upload.success", fallback: "Ready to send")
      }
    }
    internal enum Input {
      /// Enter Message
      internal static let placeholder = Localization.tr("Localizable", "chat.input.placeholder", fallback: "Enter Message")
      /// Send
      internal static let send = Localization.tr("Localizable", "chat.input.send", fallback: "Send")
    }
    internal enum Message {
      /// Send a message to start chatting
      internal static let startEngagementPlaceholder = Localization.tr("Localizable", "chat.message.start_engagement_placeholder", fallback: "Send a message to start chatting")
      internal enum Unread {
        internal enum Accessibility {
          /// Unread messages
          internal static let label = Localization.tr("Localizable", "chat.message.unread.accessibility.label", fallback: "Unread messages")
        }
      }
    }
    internal enum Operator {
      internal enum Avatar {
        internal enum Accessibility {
          /// Avatar
          internal static let label = Localization.tr("Localizable", "chat.operator.avatar.accessibility.label", fallback: "Avatar")
        }
      }
      internal enum Name {
        internal enum Accessibility {
          /// Displays operator name.
          internal static let label = Localization.tr("Localizable", "chat.operator.name.accessibility.label", fallback: "Displays operator name.")
        }
      }
    }
    internal enum Status {
      /// Delivered
      internal static let delivered = Localization.tr("Localizable", "chat.status.delivered", fallback: "Delivered")
      /// Operator typing
      internal static let typing = Localization.tr("Localizable", "chat.status.typing", fallback: "Operator typing")
    }
    internal enum Upgrade {
      internal enum Audio {
        /// Upgraded to Audio Call
        internal static let text = Localization.tr("Localizable", "chat.upgrade.audio.text", fallback: "Upgraded to Audio Call")
      }
      internal enum Video {
        /// Upgraded to Video Call
        internal static let text = Localization.tr("Localizable", "chat.upgrade.video.text", fallback: "Upgraded to Video Call")
      }
    }
    internal enum Upload {
      internal enum Remove {
        internal enum Accessibility {
          /// Remove upload
          internal static let label = Localization.tr("Localizable", "chat.upload.remove.accessibility.label", fallback: "Remove upload")
        }
      }
    }
  }
  internal enum Engagement {
    /// Operator
    internal static let defaultOperatorName = Localization.tr("Localizable", "engagement.default_operator_name", fallback: "Operator")
    /// Minimize
    internal static let minimizeVideoButton = Localization.tr("Localizable", "engagement.minimize_video_button", fallback: "Minimize")
    /// {operatorName} has offered you to upgrade
    internal static let offerUpgrade = Localization.tr("Localizable", "engagement.offer_upgrade", fallback: "{operatorName} has offered you to upgrade")
    internal enum Connect {
      /// We are here to help
      internal static let placeholder = Localization.tr("Localizable", "engagement.connect.placeholder", fallback: "We are here to help")
      /// Connecting with {operatorName}
      internal static let with = Localization.tr("Localizable", "engagement.connect.with", fallback: "Connecting with {operatorName}")
    }
    internal enum End {
      /// Are you sure you want to end engagement?
      internal static let message = Localization.tr("Localizable", "engagement.end.message", fallback: "Are you sure you want to end engagement?")
      internal enum Confirmation {
        /// End Engagement?
        internal static let header = Localization.tr("Localizable", "engagement.end.confirmation.header", fallback: "End Engagement?")
      }
    }
    internal enum Ended {
      /// Engagement Ended
      internal static let header = Localization.tr("Localizable", "engagement.ended.header", fallback: "Engagement Ended")
      /// This engagement has ended.
      /// Thank you!
      internal static let message = Localization.tr("Localizable", "engagement.ended.message", fallback: "This engagement has ended.\nThank you!")
    }
    internal enum QueueClosed {
      /// We're sorry
      internal static let header = Localization.tr("Localizable", "engagement.queue_closed.header", fallback: "We're sorry")
      /// Operators are no longer available. 
      /// Please try again later.
      internal static let message = Localization.tr("Localizable", "engagement.queue_closed.message", fallback: "Operators are no longer available. \nPlease try again later.")
    }
    internal enum QueueLeave {
      /// Are you sure you want to leave?
      internal static let header = Localization.tr("Localizable", "engagement.queue_leave.header", fallback: "Are you sure you want to leave?")
      /// You will lose your place in the queue.
      internal static let message = Localization.tr("Localizable", "engagement.queue_leave.message", fallback: "You will lose your place in the queue.")
    }
    internal enum QueueReconnectionFailed {
      /// Please try again.
      internal static let tryAgain = Localization.tr("Localizable", "engagement.queue_reconnection_failed.try_again", fallback: "Please try again.")
    }
    internal enum QueueTransferring {
      /// Transferring
      internal static let message = Localization.tr("Localizable", "engagement.queue_transferring.message", fallback: "Transferring")
    }
    internal enum QueueWait {
      /// You can continue browsing and we will connect you automatically.
      internal static let message = Localization.tr("Localizable", "engagement.queue_wait.message", fallback: "You can continue browsing and we will connect you automatically.")
    }
    internal enum SecureMessaging {
      /// Messaging
      internal static let title = Localization.tr("Localizable", "engagement.secure_messaging.title", fallback: "Messaging")
    }
  }
  internal enum Error {
    /// Something went wrong
    internal static let general = Localization.tr("Localizable", "error.general", fallback: "Something went wrong")
    /// Internal error
    internal static let `internal` = Localization.tr("Localizable", "error.internal", fallback: "Internal error")
    internal enum Unexpected {
      /// We're sorry, there has been an unexpected error.
      internal static let title = Localization.tr("Localizable", "error.unexpected.title", fallback: "We're sorry, there has been an unexpected error.")
    }
  }
  internal enum General {
    /// Accept
    internal static let accept = Localization.tr("Localizable", "general.accept", fallback: "Accept")
    /// Back
    internal static let back = Localization.tr("Localizable", "general.back", fallback: "Back")
    /// Browse
    internal static let browse = Localization.tr("Localizable", "general.browse", fallback: "Browse")
    /// Cancel
    internal static let cancel = Localization.tr("Localizable", "general.cancel", fallback: "Cancel")
    /// Close
    internal static let close = Localization.tr("Localizable", "general.close", fallback: "Close")
    /// Comment
    internal static let comment = Localization.tr("Localizable", "general.comment", fallback: "Comment")
    /// CompanyName
    internal static let companyName = Localization.tr("Localizable", "general.company_name", fallback: "CompanyName")
    /// Decline
    internal static let decline = Localization.tr("Localizable", "general.decline", fallback: "Decline")
    /// Download
    internal static let download = Localization.tr("Localizable", "general.download", fallback: "Download")
    /// End
    internal static let end = Localization.tr("Localizable", "general.end", fallback: "End")
    /// Message
    internal static let message = Localization.tr("Localizable", "general.message", fallback: "Message")
    /// No
    internal static let no = Localization.tr("Localizable", "general.no", fallback: "No")
    /// Ok
    internal static let ok = Localization.tr("Localizable", "general.ok", fallback: "Ok")
    /// Open
    internal static let `open` = Localization.tr("Localizable", "general.open", fallback: "Open")
    /// Powered by Glia
    internal static let poweredBy = Localization.tr("Localizable", "general.powered_by", fallback: "Powered by Glia")
    /// Retry
    internal static let retry = Localization.tr("Localizable", "general.retry", fallback: "Retry")
    /// Selected
    internal static let selected = Localization.tr("Localizable", "general.selected", fallback: "Selected")
    /// Submit
    internal static let submit = Localization.tr("Localizable", "general.submit", fallback: "Submit")
    /// Thank you!
    internal static let thankYou = Localization.tr("Localizable", "general.thank_you", fallback: "Thank you!")
    /// Yes
    internal static let yes = Localization.tr("Localizable", "general.yes", fallback: "Yes")
    /// You
    internal static let you = Localization.tr("Localizable", "general.you", fallback: "You")
  }
  internal enum Gva {
    /// This action is not currently supported on mobile.
    internal static let errorUnsupported = Localization.tr("Localizable", "gva.error_unsupported", fallback: "This action is not currently supported on mobile.")
  }
  internal enum Media {
    internal enum Audio {
      /// Audio
      internal static let name = Localization.tr("Localizable", "media.audio.name", fallback: "Audio")
    }
    internal enum Phone {
      /// Phone
      internal static let name = Localization.tr("Localizable", "media.phone.name", fallback: "Phone")
    }
    internal enum Text {
      /// Chat
      internal static let name = Localization.tr("Localizable", "media.text.name", fallback: "Chat")
    }
    internal enum Video {
      /// Video
      internal static let name = Localization.tr("Localizable", "media.video.name", fallback: "Video")
    }
  }
  internal enum MessageCenter {
    /// Check messages
    internal static let checkMessages = Localization.tr("Localizable", "message_center.check_messages", fallback: "Check messages")
    /// Messaging
    internal static let header = Localization.tr("Localizable", "message_center.header", fallback: "Messaging")
    internal enum Confirmation {
      /// Your message has been sent. We will get back to you within 48 hours.
      internal static let subtitle = Localization.tr("Localizable", "message_center.confirmation.subtitle", fallback: "Your message has been sent. We will get back to you within 48 hours.")
      internal enum CheckMessages {
        internal enum Accessibility {
          /// Navigates you to the chat transcript.
          internal static let hint = Localization.tr("Localizable", "message_center.confirmation.check_messages.accessibility.hint", fallback: "Navigates you to the chat transcript.")
          /// Check messages
          internal static let label = Localization.tr("Localizable", "message_center.confirmation.check_messages.accessibility.label", fallback: "Check messages")
        }
      }
    }
    internal enum NotAuthenticated {
      /// We could not verify your authentication status.
      internal static let message = Localization.tr("Localizable", "message_center.not_authenticated.message", fallback: "We could not verify your authentication status.")
    }
    internal enum Unavailable {
      /// The Message Center is currently unavailable. Please try again later.
      internal static let message = Localization.tr("Localizable", "message_center.unavailable.message", fallback: "The Message Center is currently unavailable. Please try again later.")
      /// Message Center Unavailable
      internal static let title = Localization.tr("Localizable", "message_center.unavailable.title", fallback: "Message Center Unavailable")
    }
    internal enum Welcome {
      /// The message cannot exceed 10000 characters.
      internal static let messageLengthWarning = Localization.tr("Localizable", "message_center.welcome.message_length_warning", fallback: "The message cannot exceed 10000 characters.")
      /// Your message
      internal static let messageTitle = Localization.tr("Localizable", "message_center.welcome.message_title", fallback: "Your message")
      /// Send a message and we’ll get back to you within 48 hours
      internal static let subtitle = Localization.tr("Localizable", "message_center.welcome.subtitle", fallback: "Send a message and we’ll get back to you within 48 hours")
      /// Welcome to Message Center
      internal static let title = Localization.tr("Localizable", "message_center.welcome.title", fallback: "Welcome to Message Center")
      internal enum CheckMessages {
        internal enum Accessibility {
          /// Navigates you to the chat transcript.
          internal static let hint = Localization.tr("Localizable", "message_center.welcome.check_messages.accessibility.hint", fallback: "Navigates you to the chat transcript.")
        }
      }
      internal enum FilePicker {
        internal enum Accessibility {
          /// Opens the file picker to attach media.
          internal static let hint = Localization.tr("Localizable", "message_center.welcome.file_picker.accessibility.hint", fallback: "Opens the file picker to attach media.")
          /// File picker
          internal static let label = Localization.tr("Localizable", "message_center.welcome.file_picker.accessibility.label", fallback: "File picker")
        }
      }
      internal enum MessageTextView {
        /// Enter your message
        internal static let placeholder = Localization.tr("Localizable", "message_center.welcome.message_text_view.placeholder", fallback: "Enter your message")
      }
      internal enum Send {
        internal enum Accessibility {
          /// Sends a secure message.
          internal static let hint = Localization.tr("Localizable", "message_center.welcome.send.accessibility.hint", fallback: "Sends a secure message.")
        }
      }
    }
  }
  internal enum ScreenSharing {
    internal enum VisitorScreen {
      /// End screen sharing
      internal static let end = Localization.tr("Localizable", "screen_sharing.visitor_screen.end", fallback: "End screen sharing")
      internal enum Disclaimer {
        /// You are about to share your screen
        internal static let title = Localization.tr("Localizable", "screen_sharing.visitor_screen.disclaimer.title", fallback: "You are about to share your screen")
      }
    }
  }
  internal enum Screensharing {
    internal enum VisitorScreen {
      internal enum Disclaimer {
        /// Depending on your selection, your entire screen might be shared with the operator, not just the application window.
        internal static let info = Localization.tr("Localizable", "screensharing.visitor_screen.disclaimer.info", fallback: "Depending on your selection, your entire screen might be shared with the operator, not just the application window.")
      }
    }
  }
  internal enum SendMessage {
    /// Send message
    internal static let send = Localization.tr("Localizable", "send_message.send", fallback: "Send message")
    /// Sending…
    internal static let sending = Localization.tr("Localizable", "send_message.sending", fallback: "Sending…")
  }
  internal enum Survey {
    internal enum Action {
      /// Please provide an answer.
      internal static let validationError = Localization.tr("Localizable", "survey.action.validation_error", fallback: "Please provide an answer.")
    }
    internal enum Question {
      internal enum OptionButton {
        internal enum Selected {
          internal enum Accessibility {
            /// Selected: {buttonTitle}
            internal static let label = Localization.tr("Localizable", "survey.question.option_button.selected.accessibility.label", fallback: "Selected: {buttonTitle}")
          }
        }
        internal enum Unselected {
          internal enum Accessibility {
            /// Unselected: {buttonTitle}
            internal static let label = Localization.tr("Localizable", "survey.question.option_button.unselected.accessibility.label", fallback: "Unselected: {buttonTitle}")
          }
        }
      }
      internal enum TextField {
        internal enum Accessibility {
          /// Enter the answer
          internal static let hint = Localization.tr("Localizable", "survey.question.text_field.accessibility.hint", fallback: "Enter the answer")
        }
      }
      internal enum Title {
        internal enum Accessibility {
          /// Required
          internal static let label = Localization.tr("Localizable", "survey.question.title.accessibility.label", fallback: "Required")
        }
      }
    }
    internal enum Validation {
      internal enum Title {
        internal enum Accessibility {
          /// Please provide an answer for question above
          internal static let label = Localization.tr("Localizable", "survey.validation.title.accessibility.label", fallback: "Please provide an answer for question above")
        }
      }
    }
  }
  internal enum Upgrade {
    internal enum Audio {
      /// {operatorName} has offered you to upgrade to audio
      internal static let title = Localization.tr("Localizable", "upgrade.audio.title", fallback: "{operatorName} has offered you to upgrade to audio")
    }
    internal enum Video {
      internal enum OneWay {
        /// {operatorName} has offered you to see their video
        internal static let title = Localization.tr("Localizable", "upgrade.video.one_way.title", fallback: "{operatorName} has offered you to see their video")
      }
      internal enum TwoWay {
        /// {operatorName} has offered you to upgrade to video
        internal static let title = Localization.tr("Localizable", "upgrade.video.two_way.title", fallback: "{operatorName} has offered you to upgrade to video")
      }
    }
  }
  internal enum VisitorCode {
    /// Could not load the visitor code. Please try refreshing.
    internal static let failed = Localization.tr("Localizable", "visitor_code.failed", fallback: "Could not load the visitor code. Please try refreshing.")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
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
