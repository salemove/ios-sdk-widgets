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
      internal static var settings: String { Localization.tr("Localizable", "alert.action.settings", fallback: "Settings") }
    }
    internal enum CameraAccess {
      /// Unable to access camera
      internal static var error: String { Localization.tr("Localizable", "alert.camera_access.error", fallback: "Unable to access camera") }
    }
    internal enum MediaSourceAccess {
      /// Unable to access media source
      internal static var error: String { Localization.tr("Localizable", "alert.media_source_access.error", fallback: "Unable to access media source") }
    }
    internal enum MicrophoneAccess {
      /// Unable to access microphone
      internal static var error: String { Localization.tr("Localizable", "alert.microphone_access.error", fallback: "Unable to access microphone") }
    }
    internal enum ScreenSharing {
      internal enum Start {
        /// Start Screen Sharing
        internal static var header: String { Localization.tr("Localizable", "alert.screen_sharing.start.header", fallback: "Start Screen Sharing") }
        /// {operatorName} has asked you to share your screen.
        internal static var message: String { Localization.tr("Localizable", "alert.screen_sharing.start.message", fallback: "{operatorName} has asked you to share your screen.") }
      }
      internal enum Stop {
        /// Stop Screen Sharing?
        internal static var header: String { Localization.tr("Localizable", "alert.screen_sharing.stop.header", fallback: "Stop Screen Sharing?") }
        /// Are you sure you want to stop sharing your screen?
        internal static var message: String { Localization.tr("Localizable", "alert.screen_sharing.stop.message", fallback: "Are you sure you want to stop sharing your screen?") }
      }
    }
  }
  internal enum Call {
    internal enum Bubble {
      internal enum Accessibility {
        /// Expands call view.
        internal static var hint: String { Localization.tr("Localizable", "call.bubble.accessibility.hint", fallback: "Expands call view.") }
        /// Go back to the engagement.
        internal static var label: String { Localization.tr("Localizable", "call.bubble.accessibility.label", fallback: "Go back to the engagement.") }
      }
    }
    internal enum Buttons {
      internal enum Chat {
        internal enum BadgeValue {
          internal enum MultipleItems {
            internal enum Accessibility {
              /// {badgeValue} unread messages
              internal static var label: String { Localization.tr("Localizable", "call.buttons.chat.badge_value.multiple_items.accessibility.label", fallback: "{badgeValue} unread messages") }
            }
          }
          internal enum SingleItem {
            internal enum Accessibility {
              /// {badgeValue} unread message
              internal static var label: String { Localization.tr("Localizable", "call.buttons.chat.badge_value.single_item.accessibility.label", fallback: "{badgeValue} unread message") }
            }
          }
        }
      }
    }
    internal enum Connect {
      internal enum FirstText {
        internal enum Accessibility {
          /// Displays operator name.
          internal static var hint: String { Localization.tr("Localizable", "call.connect.first_text.accessibility.hint", fallback: "Displays operator name.") }
        }
      }
      internal enum SecondText {
        internal enum Accessibility {
          /// Displays call duration.
          internal static var hint: String { Localization.tr("Localizable", "call.connect.second_text.accessibility.hint", fallback: "Displays call duration.") }
        }
      }
    }
    internal enum Duration {
      internal enum Accessibility {
        /// Call duration.
        internal static var label: String { Localization.tr("Localizable", "call.duration.accessibility.label", fallback: "Call duration.") }
      }
    }
    internal enum Header {
      internal enum Back {
        internal enum Button {
          internal enum Accessibility {
            /// Minimizes call view.
            internal static var hint: String { Localization.tr("Localizable", "call.header.back.button.accessibility.hint", fallback: "Minimizes call view.") }
          }
        }
      }
    }
    internal enum Mute {
      /// Mute
      internal static var button: String { Localization.tr("Localizable", "call.mute.button", fallback: "Mute") }
    }
    internal enum OnHold {
      /// You can continue browsing while you are on hold
      internal static var bottomText: String { Localization.tr("Localizable", "call.on_hold.bottom_text", fallback: "You can continue browsing while you are on hold") }
      /// On Hold
      internal static var icon: String { Localization.tr("Localizable", "call.on_hold.icon", fallback: "On Hold") }
    }
    internal enum OperatorAvatar {
      internal enum Accessibility {
        /// Shows operator picture.
        internal static var hint: String { Localization.tr("Localizable", "call.operator_avatar.accessibility.hint", fallback: "Shows operator picture.") }
        /// Operator Picture
        internal static var label: String { Localization.tr("Localizable", "call.operator_avatar.accessibility.label", fallback: "Operator Picture") }
      }
    }
    internal enum OperatorName {
      internal enum Accessibility {
        /// Shows operator name.
        internal static var hint: String { Localization.tr("Localizable", "call.operator_name.accessibility.hint", fallback: "Shows operator name.") }
      }
    }
    internal enum OperatorVideo {
      internal enum Accessibility {
        /// Operator's Video
        internal static var label: String { Localization.tr("Localizable", "call.operator_video.accessibility.label", fallback: "Operator's Video") }
      }
    }
    internal enum Speaker {
      /// Speaker
      internal static var button: String { Localization.tr("Localizable", "call.speaker.button", fallback: "Speaker") }
    }
    internal enum Unmute {
      /// Unmute
      internal static var button: String { Localization.tr("Localizable", "call.unmute.button", fallback: "Unmute") }
    }
    internal enum VisitorVideo {
      internal enum Accessibility {
        /// Your Video
        internal static var label: String { Localization.tr("Localizable", "call.visitor_video.accessibility.label", fallback: "Your Video") }
      }
    }
  }
  internal enum CallVisualizer {
    internal enum ScreenSharing {
      /// Your Screen is Being Shared
      internal static var message: String { Localization.tr("Localizable", "call_visualizer.screen_sharing.message", fallback: "Your Screen is Being Shared") }
      internal enum Header {
        /// Screen Sharing
        internal static var title: String { Localization.tr("Localizable", "call_visualizer.screen_sharing.header.title", fallback: "Screen Sharing") }
      }
    }
    internal enum VisitorCode {
      /// Your Visitor Code
      internal static var title: String { Localization.tr("Localizable", "call_visualizer.visitor_code.title", fallback: "Your Visitor Code") }
      internal enum Close {
        internal enum Accessibility {
          /// Closes the visitor code
          internal static var hint: String { Localization.tr("Localizable", "call_visualizer.visitor_code.close.accessibility.hint", fallback: "Closes the visitor code") }
        }
      }
      internal enum Refresh {
        internal enum Accessibility {
          /// Generates a new visitor code
          internal static var hint: String { Localization.tr("Localizable", "call_visualizer.visitor_code.refresh.accessibility.hint", fallback: "Generates a new visitor code") }
          /// Refresh Button
          internal static var label: String { Localization.tr("Localizable", "call_visualizer.visitor_code.refresh.accessibility.label", fallback: "Refresh Button") }
        }
      }
      internal enum Title {
        internal enum Accessibility {
          /// Shows the five-digit visitor code.
          internal static var hint: String { Localization.tr("Localizable", "call_visualizer.visitor_code.title.accessibility.hint", fallback: "Shows the five-digit visitor code.") }
        }
      }
    }
  }
  internal enum Chat {
    /// Pick attachment
    internal static var attachFiles: String { Localization.tr("Localizable", "chat.attach_files", fallback: "Pick attachment") }
    /// New Messages
    internal static var unreadMessageDivider: String { Localization.tr("Localizable", "chat.unread_message_divider", fallback: "New Messages") }
    internal enum Attachment {
      /// Photo Library
      internal static var photoLibrary: String { Localization.tr("Localizable", "chat.attachment.photo_library", fallback: "Photo Library") }
      /// Take Photo or Video
      internal static var takePhoto: String { Localization.tr("Localizable", "chat.attachment.take_photo", fallback: "Take Photo or Video") }
      /// This file type is not supported.
      internal static var unsupportedFile: String { Localization.tr("Localizable", "chat.attachment.unsupported_file", fallback: "This file type is not supported.") }
      internal enum Message {
        internal enum Accessibility {
          /// Attachment from {fileSender}
          internal static var label: String { Localization.tr("Localizable", "chat.attachment.message.accessibility.label", fallback: "Attachment from {fileSender}") }
        }
      }
    }
    internal enum ChoiceCard {
      /// Tap on the answer above
      internal static var placeholderMessage: String { Localization.tr("Localizable", "chat.choice_card.placeholder_message", fallback: "Tap on the answer above") }
      internal enum Button {
        internal enum Disabled {
          internal enum Accessibility {
            /// Disabled
            internal static var label: String { Localization.tr("Localizable", "chat.choice_card.button.disabled.accessibility.label", fallback: "Disabled") }
          }
        }
      }
      internal enum Image {
        internal enum Accessibility {
          /// Choice card
          internal static var label: String { Localization.tr("Localizable", "chat.choice_card.image.accessibility.label", fallback: "Choice card") }
        }
      }
    }
    internal enum Download {
      /// Downloading file…
      internal static var downloading: String { Localization.tr("Localizable", "chat.download.downloading", fallback: "Downloading file…") }
      /// Could not download the file.
      internal static var failed: String { Localization.tr("Localizable", "chat.download.failed", fallback: "Could not download the file.") }
    }
    internal enum File {
      internal enum InfectedFile {
        /// The safety of the file could not be confirmed.
        internal static var error: String { Localization.tr("Localizable", "chat.file.infected_file.error", fallback: "The safety of the file could not be confirmed.") }
      }
      internal enum RemoveUpload {
        internal enum Accessibility {
          /// Remove upload
          internal static var label: String { Localization.tr("Localizable", "chat.file.remove_upload.accessibility.label", fallback: "Remove upload") }
        }
      }
      internal enum SizeLimit {
        /// File size must be less than 25 MB.
        internal static var error: String { Localization.tr("Localizable", "chat.file.size_limit.error", fallback: "File size must be less than 25 MB.") }
      }
      internal enum Upload {
        /// Could not upload the file.
        internal static var failed: String { Localization.tr("Localizable", "chat.file.upload.failed", fallback: "Could not upload the file.") }
        /// Could not upload the file.
        internal static var genericError: String { Localization.tr("Localizable", "chat.file.upload.generic_error", fallback: "Could not upload the file.") }
        /// Uploading file…
        internal static var inProgress: String { Localization.tr("Localizable", "chat.file.upload.in_progress", fallback: "Uploading file…") }
        /// Could not upload the file due to a network issue.
        internal static var networkError: String { Localization.tr("Localizable", "chat.file.upload.network_error", fallback: "Could not upload the file due to a network issue.") }
        /// Checking file security…
        internal static var scanning: String { Localization.tr("Localizable", "chat.file.upload.scanning", fallback: "Checking file security…") }
        /// Ready to send
        internal static var success: String { Localization.tr("Localizable", "chat.file.upload.success", fallback: "Ready to send") }
      }
    }
    internal enum Input {
      /// Enter Message
      internal static var placeholder: String { Localization.tr("Localizable", "chat.input.placeholder", fallback: "Enter Message") }
    }
    internal enum MediaUpgrade {
      internal enum Audio {
        /// Upgraded to Audio
        internal static var systemMessage: String { Localization.tr("Localizable", "chat.media_upgrade.audio.system_message", fallback: "Upgraded to Audio") }
      }
      internal enum Video {
        /// Upgraded to Video
        internal static var systemMessage: String { Localization.tr("Localizable", "chat.media_upgrade.video.system_message", fallback: "Upgraded to Video") }
      }
    }
    internal enum Message {
      /// Delivered
      internal static var delivered: String { Localization.tr("Localizable", "chat.message.delivered", fallback: "Delivered") }
      /// Send a message to start chatting
      internal static var startEngagementPlaceholder: String { Localization.tr("Localizable", "chat.message.start_engagement_placeholder", fallback: "Send a message to start chatting") }
      internal enum Unread {
        internal enum Accessibility {
          /// Unread messages
          internal static var label: String { Localization.tr("Localizable", "chat.message.unread.accessibility.label", fallback: "Unread messages") }
        }
      }
    }
    internal enum OperatorAvatar {
      internal enum Accessibility {
        /// Operator Picture
        internal static var label: String { Localization.tr("Localizable", "chat.operator_avatar.accessibility.label", fallback: "Operator Picture") }
      }
    }
    internal enum OperatorJoined {
      /// {operatorName} has joined the conversation.
      internal static var systemMessage: String { Localization.tr("Localizable", "chat.operator_joined.system_message", fallback: "{operatorName} has joined the conversation.") }
    }
    internal enum OperatorName {
      internal enum Accessibility {
        /// Operator Name
        internal static var label: String { Localization.tr("Localizable", "chat.operator_name.accessibility.label", fallback: "Operator Name") }
      }
    }
    internal enum Status {
      /// Operator is typing
      internal static var typing: String { Localization.tr("Localizable", "chat.status.typing", fallback: "Operator is typing") }
      internal enum Typing {
        internal enum Accessibility {
          /// {operatorName} is typing
          internal static var label: String { Localization.tr("Localizable", "chat.status.typing.accessibility.label", fallback: "{operatorName} is typing") }
        }
      }
    }
  }
  internal enum Engagement {
    /// Operator
    internal static var defaultOperator: String { Localization.tr("Localizable", "engagement.default_operator", fallback: "Operator") }
    internal enum Audio {
      /// Audio
      internal static var title: String { Localization.tr("Localizable", "engagement.audio.title", fallback: "Audio") }
    }
    internal enum Chat {
      /// Chat
      internal static var title: String { Localization.tr("Localizable", "engagement.chat.title", fallback: "Chat") }
    }
    internal enum ConnectionScreen {
      /// Connecting with {operatorName}
      internal static var connectWith: String { Localization.tr("Localizable", "engagement.connection_screen.connect_with", fallback: "Connecting with {operatorName}") }
      /// We are here to help!
      internal static var message: String { Localization.tr("Localizable", "engagement.connection_screen.message", fallback: "We are here to help!") }
    }
    internal enum End {
      /// Are you sure you want to end this engagement?
      internal static var message: String { Localization.tr("Localizable", "engagement.end.message", fallback: "Are you sure you want to end this engagement?") }
      internal enum Confirmation {
        /// End Engagement?
        internal static var header: String { Localization.tr("Localizable", "engagement.end.confirmation.header", fallback: "End Engagement?") }
      }
    }
    internal enum Ended {
      /// Engagement Ended
      internal static var header: String { Localization.tr("Localizable", "engagement.ended.header", fallback: "Engagement Ended") }
      /// This engagement has ended.
      /// Thank you!
      internal static var message: String { Localization.tr("Localizable", "engagement.ended.message", fallback: "This engagement has ended.\nThank you!") }
    }
    internal enum MediaUpgrade {
      /// {operatorName} has offered you to upgrade.
      internal static var offer: String { Localization.tr("Localizable", "engagement.media_upgrade.offer", fallback: "{operatorName} has offered you to upgrade.") }
      internal enum Audio {
        /// Speak through your device
        internal static var info: String { Localization.tr("Localizable", "engagement.media_upgrade.audio.info", fallback: "Speak through your device") }
      }
      internal enum Phone {
        /// Enter your number and will call you back.
        internal static var info: String { Localization.tr("Localizable", "engagement.media_upgrade.phone.info", fallback: "Enter your number and will call you back.") }
      }
    }
    internal enum MinimizeVideo {
      /// Minimize
      internal static var button: String { Localization.tr("Localizable", "engagement.minimize_video.button", fallback: "Minimize") }
    }
    internal enum Phone {
      /// Phone
      internal static var title: String { Localization.tr("Localizable", "engagement.phone.title", fallback: "Phone") }
    }
    internal enum Queue {
      /// Transferring
      internal static var transferring: String { Localization.tr("Localizable", "engagement.queue.transferring", fallback: "Transferring") }
      internal enum Closed {
        /// We are sorry! The queue is closed.
        internal static var header: String { Localization.tr("Localizable", "engagement.queue.closed.header", fallback: "We are sorry! The queue is closed.") }
        /// Operators are no longer available. 
        /// Please try again later.
        internal static var message: String { Localization.tr("Localizable", "engagement.queue.closed.message", fallback: "Operators are no longer available. \nPlease try again later.") }
      }
      internal enum Leave {
        /// Are you sure you want to leave?
        internal static var header: String { Localization.tr("Localizable", "engagement.queue.leave.header", fallback: "Are you sure you want to leave?") }
        /// You will lose your place in the queue.
        internal static var message: String { Localization.tr("Localizable", "engagement.queue.leave.message", fallback: "You will lose your place in the queue.") }
      }
      internal enum Reconnection {
        /// Please try again later.
        internal static var failed: String { Localization.tr("Localizable", "engagement.queue.reconnection.failed", fallback: "Please try again later.") }
      }
    }
    internal enum QueueWait {
      /// You can continue browsing and we will connect you automatically.
      internal static var message: String { Localization.tr("Localizable", "engagement.queue_wait.message", fallback: "You can continue browsing and we will connect you automatically.") }
    }
    internal enum SecureMessaging {
      /// Messaging
      internal static var title: String { Localization.tr("Localizable", "engagement.secure_messaging.title", fallback: "Messaging") }
    }
    internal enum Video {
      /// Video
      internal static var title: String { Localization.tr("Localizable", "engagement.video.title", fallback: "Video") }
    }
  }
  internal enum Error {
    /// Something went wrong.
    internal static var general: String { Localization.tr("Localizable", "error.general", fallback: "Something went wrong.") }
    /// Something went wrong.
    internal static var `internal`: String { Localization.tr("Localizable", "error.internal", fallback: "Something went wrong.") }
    /// Something went wrong.
    internal static var unexpected: String { Localization.tr("Localizable", "error.unexpected", fallback: "Something went wrong.") }
  }
  internal enum General {
    /// Accept
    internal static var accept: String { Localization.tr("Localizable", "general.accept", fallback: "Accept") }
    /// Back
    internal static var back: String { Localization.tr("Localizable", "general.back", fallback: "Back") }
    /// Browse
    internal static var browse: String { Localization.tr("Localizable", "general.browse", fallback: "Browse") }
    /// Cancel
    internal static var cancel: String { Localization.tr("Localizable", "general.cancel", fallback: "Cancel") }
    /// Close
    internal static var close: String { Localization.tr("Localizable", "general.close", fallback: "Close") }
    /// Comment
    internal static var comment: String { Localization.tr("Localizable", "general.comment", fallback: "Comment") }
    /// Company Name
    internal static var companyName: String { Localization.tr("Localizable", "general.company_name", fallback: "Company Name") }
    /// Company Name without asking string provider
    internal static var companyNameLocalFallbackOnly: String { Localization.tr("Localizable", "general.company_name", fallback: "Company Name", stringProviding: nil) }
    /// Decline
    internal static var decline: String { Localization.tr("Localizable", "general.decline", fallback: "Decline") }
    /// Download
    internal static var download: String { Localization.tr("Localizable", "general.download", fallback: "Download") }
    /// End
    internal static var end: String { Localization.tr("Localizable", "general.end", fallback: "End") }
    /// Message
    internal static var message: String { Localization.tr("Localizable", "general.message", fallback: "Message") }
    /// No
    internal static var no: String { Localization.tr("Localizable", "general.no", fallback: "No") }
    /// Ok
    internal static var ok: String { Localization.tr("Localizable", "general.ok", fallback: "Ok") }
    /// Open
    internal static var `open`: String { Localization.tr("Localizable", "general.open", fallback: "Open") }
    /// Powered by
    internal static var powered: String { Localization.tr("Localizable", "general.powered", fallback: "Powered by") }
    /// Refresh
    internal static var refresh: String { Localization.tr("Localizable", "general.refresh", fallback: "Refresh") }
    /// Retry
    internal static var retry: String { Localization.tr("Localizable", "general.retry", fallback: "Retry") }
    /// Selected
    internal static var selected: String { Localization.tr("Localizable", "general.selected", fallback: "Selected") }
    /// Send
    internal static var send: String { Localization.tr("Localizable", "general.send", fallback: "Send") }
    /// Sending…
    internal static var sending: String { Localization.tr("Localizable", "general.sending", fallback: "Sending…") }
    /// Submit
    internal static var submit: String { Localization.tr("Localizable", "general.submit", fallback: "Submit") }
    /// Thank you!
    internal static var thankYou: String { Localization.tr("Localizable", "general.thank_you", fallback: "Thank you!") }
    /// Yes
    internal static var yes: String { Localization.tr("Localizable", "general.yes", fallback: "Yes") }
    /// You
    internal static var you: String { Localization.tr("Localizable", "general.you", fallback: "You") }
    internal enum Close {
      /// Close Button
      internal static var accessibility: String { Localization.tr("Localizable", "general.close.accessibility", fallback: "Close Button") }
    }
  }
  internal enum Gva {
    internal enum UnsupportedAction {
      /// This action is not currently supported on mobile.
      internal static var error: String { Localization.tr("Localizable", "gva.unsupported_action.error", fallback: "This action is not currently supported on mobile.") }
    }
  }
  internal enum Ios {
    internal enum Alert {
      internal enum CameraAccess {
        /// Allow access to your camera in 'Settings' - 'Privacy & Security' - 'Camera'
        internal static var message: String { Localization.tr("Localizable", "ios.alert.camera_access.message", fallback: "Allow access to your camera in 'Settings' - 'Privacy & Security' - 'Camera'") }
      }
      internal enum MediaSource {
        /// This media source is not available on your device
        internal static var message: String { Localization.tr("Localizable", "ios.alert.media_source.message", fallback: "This media source is not available on your device") }
      }
      internal enum MicrophoneAccess {
        /// Allow access to your microphone in 'Settings' - 'Privacy & Security' - 'Microphone'
        internal static var message: String { Localization.tr("Localizable", "ios.alert.microphone_access.message", fallback: "Allow access to your microphone in 'Settings' - 'Privacy & Security' - 'Microphone'") }
      }
    }
    internal enum Engagement {
      internal enum ConnectionScreen {
        /// (By default, your video will be turned off)
        internal static var videoNotice: String { Localization.tr("Localizable", "ios.engagement.connection_screen.video_notice", fallback: "(By default, your video will be turned off)") }
      }
    }
  }
  internal enum MediaUpgrade {
    internal enum Audio {
      /// {operatorName} has offered you to upgrade to audio
      internal static var title: String { Localization.tr("Localizable", "media_upgrade.audio.title", fallback: "{operatorName} has offered you to upgrade to audio") }
    }
    internal enum Video {
      internal enum OneWay {
        /// {operatorName} has offered you to see their video
        internal static var title: String { Localization.tr("Localizable", "media_upgrade.video.one_way.title", fallback: "{operatorName} has offered you to see their video") }
      }
      internal enum TwoWay {
        /// {operatorName} has offered you to upgrade to video
        internal static var title: String { Localization.tr("Localizable", "media_upgrade.video.two_way.title", fallback: "{operatorName} has offered you to upgrade to video") }
      }
    }
  }
  internal enum MessageCenter {
    /// Messaging
    internal static var header: String { Localization.tr("Localizable", "message_center.header", fallback: "Messaging") }
    internal enum Confirmation {
      /// Your message has been sent. We will get back to you within 48 hours.
      internal static var subtitle: String { Localization.tr("Localizable", "message_center.confirmation.subtitle", fallback: "Your message has been sent. We will get back to you within 48 hours.") }
      internal enum CheckMessages {
        internal enum Accessibility {
          /// Navigates you to the chat transcript.
          internal static var hint: String { Localization.tr("Localizable", "message_center.confirmation.check_messages.accessibility.hint", fallback: "Navigates you to the chat transcript.") }
          /// Check messages
          internal static var label: String { Localization.tr("Localizable", "message_center.confirmation.check_messages.accessibility.label", fallback: "Check messages") }
        }
      }
    }
    internal enum NotAuthenticated {
      /// We could not verify your authentication status.
      internal static var message: String { Localization.tr("Localizable", "message_center.not_authenticated.message", fallback: "We could not verify your authentication status.") }
    }
    internal enum Unavailable {
      /// The Message Center is currently unavailable. Please try again later.
      internal static var message: String { Localization.tr("Localizable", "message_center.unavailable.message", fallback: "The Message Center is currently unavailable. Please try again later.") }
      /// Message Center Unavailable
      internal static var title: String { Localization.tr("Localizable", "message_center.unavailable.title", fallback: "Message Center Unavailable") }
    }
    internal enum Welcome {
      /// Check messages
      internal static var checkMessages: String { Localization.tr("Localizable", "message_center.welcome.check_messages", fallback: "Check messages") }
      /// Your message
      internal static var messageTitle: String { Localization.tr("Localizable", "message_center.welcome.message_title", fallback: "Your message") }
      /// Send a message and we will get back to you within 48 hours.
      internal static var subtitle: String { Localization.tr("Localizable", "message_center.welcome.subtitle", fallback: "Send a message and we will get back to you within 48 hours.") }
      /// Welcome to Message Center
      internal static var title: String { Localization.tr("Localizable", "message_center.welcome.title", fallback: "Welcome to Message Center") }
      internal enum CheckMessages {
        internal enum Accessibility {
          /// Navigates you to the chat transcript.
          internal static var hint: String { Localization.tr("Localizable", "message_center.welcome.check_messages.accessibility.hint", fallback: "Navigates you to the chat transcript.") }
        }
      }
      internal enum FilePicker {
        internal enum Accessibility {
          /// Opens the file picker to attach media.
          internal static var hint: String { Localization.tr("Localizable", "message_center.welcome.file_picker.accessibility.hint", fallback: "Opens the file picker to attach media.") }
          /// File picker
          internal static var label: String { Localization.tr("Localizable", "message_center.welcome.file_picker.accessibility.label", fallback: "File picker") }
        }
      }
      internal enum MessageInput {
        /// Enter your message
        internal static var placeholder: String { Localization.tr("Localizable", "message_center.welcome.message_input.placeholder", fallback: "Enter your message") }
      }
      internal enum MessageLength {
        /// The message cannot exceed 10,000 characters.
        internal static var error: String { Localization.tr("Localizable", "message_center.welcome.message_length.error", fallback: "The message cannot exceed 10,000 characters.") }
      }
      internal enum Send {
        internal enum Accessibility {
          /// Sends a secure message.
          internal static var hint: String { Localization.tr("Localizable", "message_center.welcome.send.accessibility.hint", fallback: "Sends a secure message.") }
        }
      }
    }
  }
  internal enum ScreenSharing {
    internal enum VisitorScreen {
      internal enum Disclaimer {
        /// Depending on your selection, your entire screen might be shared with the operator, not just the application window.
        internal static var info: String { Localization.tr("Localizable", "screen_sharing.visitor_screen.disclaimer.info", fallback: "Depending on your selection, your entire screen might be shared with the operator, not just the application window.") }
        /// You are about to share your screen
        internal static var title: String { Localization.tr("Localizable", "screen_sharing.visitor_screen.disclaimer.title", fallback: "You are about to share your screen") }
      }
      internal enum End {
        /// End Screen Sharing
        internal static var title: String { Localization.tr("Localizable", "screen_sharing.visitor_screen.end.title", fallback: "End Screen Sharing") }
        internal enum Accessibility {
          /// Ends screen sharing
          internal static var hint: String { Localization.tr("Localizable", "screen_sharing.visitor_screen.end.accessibility.hint", fallback: "Ends screen sharing") }
        }
      }
    }
  }
  internal enum Survey {
    internal enum Action {
      /// Please provide an answer.
      internal static var validationError: String { Localization.tr("Localizable", "survey.action.validation_error", fallback: "Please provide an answer.") }
    }
    internal enum Question {
      internal enum Input {
        internal enum Accessibility {
          /// Enter the answer
          internal static var hint: String { Localization.tr("Localizable", "survey.question.input.accessibility.hint", fallback: "Enter the answer") }
        }
      }
      internal enum OptionButton {
        internal enum Selected {
          internal enum Accessibility {
            /// Selected: {buttonTitle}
            internal static var label: String { Localization.tr("Localizable", "survey.question.option_button.selected.accessibility.label", fallback: "Selected: {buttonTitle}") }
          }
        }
        internal enum Unselected {
          internal enum Accessibility {
            /// Unselected: {buttonTitle}
            internal static var label: String { Localization.tr("Localizable", "survey.question.option_button.unselected.accessibility.label", fallback: "Unselected: {buttonTitle}") }
          }
        }
      }
      internal enum Required {
        internal enum Accessibility {
          /// This is a required question.
          internal static var label: String { Localization.tr("Localizable", "survey.question.required.accessibility.label", fallback: "This is a required question.") }
        }
      }
    }
    internal enum Validation {
      internal enum Title {
        internal enum Accessibility {
          /// Please provide an answer for the question above.
          internal static var label: String { Localization.tr("Localizable", "survey.validation.title.accessibility.label", fallback: "Please provide an answer for the question above.") }
        }
      }
    }
  }
  internal enum VisitorCode {
    /// Could not load the visitor code. Please try refreshing.
    internal static var failed: String { Localization.tr("Localizable", "visitor_code.failed", fallback: "Could not load the visitor code. Please try refreshing.") }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// swiftlint:enable all
