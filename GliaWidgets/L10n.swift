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
    public enum Accessibility {
      public enum Action {
        /// Accept
        public static let accept = L10n.tr("Localizable", "alert.accessibility.action.accept")
        /// Cancel
        public static let cancel = L10n.tr("Localizable", "alert.accessibility.action.cancel")
        /// Decline
        public static let decline = L10n.tr("Localizable", "alert.accessibility.action.decline")
        /// No
        public static let no = L10n.tr("Localizable", "alert.accessibility.action.no")
        /// OK
        public static let ok = L10n.tr("Localizable", "alert.accessibility.action.ok")
        /// Settings
        public static let settings = L10n.tr("Localizable", "alert.accessibility.action.settings")
        /// Yes
        public static let yes = L10n.tr("Localizable", "alert.accessibility.action.yes")
      }
    }
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
    public enum Accessibility {
      public enum Bubble {
        /// Deactivates minimize.
        public static let hint = L10n.tr("Localizable", "call.accessibility.bubble.hint")
        /// Operator Avatar
        public static let label = L10n.tr("Localizable", "call.accessibility.bubble.label")
      }
      public enum Buttons {
        public enum Chat {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Localizable", "call.accessibility.buttons.chat.titleAndBadgeValue")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.chat.active.label")
          }
          public enum BadgeValue {
            /// {badgeValue} unread messages
            public static let multipleItems = L10n.tr("Localizable", "call.accessibility.buttons.chat.badgeValue.multipleItems")
            /// {badgeValue} unread message
            public static let singleItem = L10n.tr("Localizable", "call.accessibility.buttons.chat.badgeValue.singleItem")
          }
          public enum Inactive {
            /// 
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.chat.inactive.label")
          }
        }
        public enum Minimize {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Localizable", "call.accessibility.buttons.minimize.titleAndBadgeValue")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.minimize.active.label")
          }
          public enum BadgeValue {
            /// 
            public static let multipleItems = L10n.tr("Localizable", "call.accessibility.buttons.minimize.badgeValue.multipleItems")
            /// 
            public static let singleItem = L10n.tr("Localizable", "call.accessibility.buttons.minimize.badgeValue.singleItem")
          }
          public enum Inactive {
            /// 
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.minimize.inactive.label")
          }
        }
        public enum Mute {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Localizable", "call.accessibility.buttons.mute.titleAndBadgeValue")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.mute.active.label")
          }
          public enum BadgeValue {
            /// 
            public static let multipleItems = L10n.tr("Localizable", "call.accessibility.buttons.mute.badgeValue.multipleItems")
            /// 
            public static let singleItem = L10n.tr("Localizable", "call.accessibility.buttons.mute.badgeValue.singleItem")
          }
          public enum Inactive {
            /// 
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.mute.inactive.label")
          }
        }
        public enum Speaker {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Localizable", "call.accessibility.buttons.speaker.titleAndBadgeValue")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.speaker.active.label")
          }
          public enum BadgeValue {
            /// 
            public static let multipleItems = L10n.tr("Localizable", "call.accessibility.buttons.speaker.badgeValue.multipleItems")
            /// 
            public static let singleItem = L10n.tr("Localizable", "call.accessibility.buttons.speaker.badgeValue.singleItem")
          }
          public enum Inactive {
            /// 
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.speaker.inactive.label")
          }
        }
        public enum Video {
          /// {buttonTitle}, {badgeValue}
          public static let titleAndBadgeValue = L10n.tr("Localizable", "call.accessibility.buttons.video.titleAndBadgeValue")
          public enum Active {
            /// Selected
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.video.active.label")
          }
          public enum BadgeValue {
            /// 
            public static let multipleItems = L10n.tr("Localizable", "call.accessibility.buttons.video.badgeValue.multipleItems")
            /// 
            public static let singleItem = L10n.tr("Localizable", "call.accessibility.buttons.video.badgeValue.singleItem")
          }
          public enum Inactive {
            /// 
            public static let label = L10n.tr("Localizable", "call.accessibility.buttons.video.inactive.label")
          }
        }
      }
      public enum CallDuration {
        /// Displays call duration.
        public static let hint = L10n.tr("Localizable", "call.accessibility.callDuration.hint")
      }
      public enum Connect {
        public enum Connected {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Localizable", "call.accessibility.connect.connected.firstText.hint")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "call.accessibility.connect.connected.secondText.hint")
          }
        }
        public enum Connecting {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Localizable", "call.accessibility.connect.connecting.firstText.hint")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "call.accessibility.connect.connecting.secondText.hint")
          }
        }
        public enum Queue {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Localizable", "call.accessibility.connect.queue.firstText.hint")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "call.accessibility.connect.queue.secondText.hint")
          }
        }
      }
      public enum Header {
        public enum BackButton {
          /// Activates minimize.
          public static let hint = L10n.tr("Localizable", "call.accessibility.header.backButton.hint")
          /// Back
          public static let label = L10n.tr("Localizable", "call.accessibility.header.backButton.label")
        }
        public enum CloseButton {
          /// 
          public static let hint = L10n.tr("Localizable", "call.accessibility.header.closeButton.hint")
          /// Close
          public static let label = L10n.tr("Localizable", "call.accessibility.header.closeButton.label")
        }
        public enum EndButton {
          /// End
          public static let label = L10n.tr("Localizable", "call.accessibility.header.endButton.label")
        }
        public enum EndScreenShareButton {
          /// 
          public static let hint = L10n.tr("Localizable", "call.accessibility.header.endScreenShareButton.hint")
          /// End
          public static let label = L10n.tr("Localizable", "call.accessibility.header.endScreenShareButton.label")
        }
      }
      public enum Operator {
        public enum Avatar {
          /// Displays operator avatar or placeholder.
          public static let hint = L10n.tr("Localizable", "call.accessibility.operator.avatar.hint")
          /// Avatar
          public static let label = L10n.tr("Localizable", "call.accessibility.operator.avatar.label")
        }
      }
      public enum OperatorName {
        /// Displays operator name.
        public static let hint = L10n.tr("Localizable", "call.accessibility.operatorName.hint")
      }
      public enum Video {
        public enum Operator {
          /// Operator's Video
          public static let label = L10n.tr("Localizable", "call.accessibility.video.operator.label")
        }
        public enum Visitor {
          /// Your Video
          public static let label = L10n.tr("Localizable", "call.accessibility.video.visitor.label")
        }
      }
    }
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
    public enum Accessibility {
      /// You
      public static let visitorName = L10n.tr("Localizable", "chat.accessibility.visitorName")
      public enum ChatCallUpgrade {
        public enum Audio {
          public enum Duration {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.chatCallUpgrade.audio.duration.hint")
          }
        }
        public enum Video {
          public enum Duration {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.chatCallUpgrade.video.duration.hint")
          }
        }
      }
      public enum Connect {
        public enum Connected {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.connect.connected.firstText.hint")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.connect.connected.secondText.hint")
          }
        }
        public enum Connecting {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.connect.connecting.firstText.hint")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.connect.connecting.secondText.hint")
          }
        }
        public enum Queue {
          public enum FirstText {
            /// Displays operator name.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.connect.queue.firstText.hint")
          }
          public enum SecondText {
            /// Displays call duration.
            public static let hint = L10n.tr("Localizable", "chat.accessibility.connect.queue.secondText.hint")
          }
        }
      }
      public enum Download {
        public enum State {
          /// {downloadedFileName}, {downloadedFileState}
          public static let downloaded = L10n.tr("Localizable", "chat.accessibility.download.state.downloaded")
          /// {downloadedFileName}, {downloadedFileState} {downloadPercentValue}%%
          public static let downloading = L10n.tr("Localizable", "chat.accessibility.download.state.downloading")
          /// {downloadedFileName}, {downloadedFileState}
          public static let error = L10n.tr("Localizable", "chat.accessibility.download.state.error")
          /// {downloadedFileName}, {downloadedFileState}
          public static let `none` = L10n.tr("Localizable", "chat.accessibility.download.state.none")
        }
      }
      public enum Header {
        public enum BackButton {
          /// 
          public static let hint = L10n.tr("Localizable", "chat.accessibility.header.backButton.hint")
          /// back
          public static let label = L10n.tr("Localizable", "chat.accessibility.header.backButton.label")
        }
        public enum CloseButton {
          /// 
          public static let hint = L10n.tr("Localizable", "chat.accessibility.header.closeButton.hint")
          /// Close
          public static let label = L10n.tr("Localizable", "chat.accessibility.header.closeButton.label")
        }
        public enum EndButton {
          /// End
          public static let label = L10n.tr("Localizable", "chat.accessibility.header.endButton.label")
        }
        public enum EndScreenShareButton {
          /// 
          public static let hint = L10n.tr("Localizable", "chat.accessibility.header.endScreenShareButton.hint")
          /// End
          public static let label = L10n.tr("Localizable", "chat.accessibility.header.endScreenShareButton.label")
        }
      }
      public enum Message {
        /// Attachment from {fileSender}
        public static let attachmentMessageLabel = L10n.tr("Localizable", "chat.accessibility.message.attachmentMessageLabel")
        /// You
        public static let you = L10n.tr("Localizable", "chat.accessibility.message.you")
        public enum ChoiceCard {
          public enum ButtonState {
            /// Disabled
            public static let disabled = L10n.tr("Localizable", "chat.accessibility.message.choiceCard.buttonState.disabled")
            /// 
            public static let normal = L10n.tr("Localizable", "chat.accessibility.message.choiceCard.buttonState.normal")
            /// Selected
            public static let selected = L10n.tr("Localizable", "chat.accessibility.message.choiceCard.buttonState.selected")
          }
          public enum Image {
            /// Choice card
            public static let label = L10n.tr("Localizable", "chat.accessibility.message.choiceCard.image.label")
          }
        }
        public enum MessageInput {
          /// Message
          public static let label = L10n.tr("Localizable", "chat.accessibility.message.messageInput.label")
        }
        public enum Operator {
          public enum TypingIndicator {
            /// {operatorName} is typing
            public static let label = L10n.tr("Localizable", "chat.accessibility.message.operator.typingIndicator.label")
          }
        }
        public enum SendButton {
          /// Send
          public static let label = L10n.tr("Localizable", "chat.accessibility.message.sendButton.label")
        }
        public enum UnreadMessagesIndicator {
          /// Unread messages
          public static let label = L10n.tr("Localizable", "chat.accessibility.message.unreadMessagesIndicator.label")
        }
      }
      public enum Operator {
        public enum Avatar {
          /// Displays operator avatar or placeholder.
          public static let hint = L10n.tr("Localizable", "chat.accessibility.operator.avatar.hint")
          /// Avatar
          public static let label = L10n.tr("Localizable", "chat.accessibility.operator.avatar.label")
        }
      }
      public enum PickMedia {
        public enum PickAttachmentButton {
          /// Pick attachment
          public static let label = L10n.tr("Localizable", "chat.accessibility.pickMedia.pickAttachmentButton.label")
        }
      }
      public enum Upload {
        public enum Progress {
          /// {uploadedFileName}, {uploadPercentValue}%%
          public static let fileNameWithProgressValue = L10n.tr("Localizable", "chat.accessibility.upload.progress.fileNameWithProgressValue")
          /// {uploadPercentValue}%%
          public static let percentValue = L10n.tr("Localizable", "chat.accessibility.upload.progress.percentValue")
        }
        public enum RemoveUpload {
          /// Remove upload
          public static let label = L10n.tr("Localizable", "chat.accessibility.upload.removeUpload.label")
        }
      }
    }
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
