// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings



// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
struct L10nX {
  let alertObj: Alert
  struct Alert {
      let actionObj: Action
      struct Action {
        let settings: String
      }
      let cameraAccessObj: CameraAccess
      struct CameraAccess {
        let error: String
      }
      let mediaSourceAccessObj: MediaSourceAccess
      struct MediaSourceAccess {
        let error: String
      }
      let microphoneAccessObj: MicrophoneAccess
      struct MicrophoneAccess {
        let error: String
      }
      let screenSharingObj: ScreenSharing
      struct ScreenSharing {
          let startObj: Start
          struct Start {
            let header: String
            let message: String
          }
          let stopObj: Stop
          struct Stop {
            let header: String
            let message: String
          }
      }
  }
  let callObj: Call
  struct Call {
      let bubbleObj: Bubble
      struct Bubble {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let hint: String
            let label: String
          }
      }
      let buttonsObj: Buttons
      struct Buttons {
          let chatObj: Chat
          struct Chat {
              let badgeValueObj: BadgeValue
              struct BadgeValue {
                  let multipleItemsObj: MultipleItems
                  struct MultipleItems {
                      let accessibilityObj: Accessibility
                      struct Accessibility {
                        let label: String
                      }
                  }
                  let singleItemObj: SingleItem
                  struct SingleItem {
                      let accessibilityObj: Accessibility
                      struct Accessibility {
                        let label: String
                      }
                  }
              }
          }
      }
      let connectObj: Connect
      struct Connect {
          let firstTextObj: FirstText
          struct FirstText {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let secondTextObj: SecondText
          struct SecondText {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
      let durationObj: Duration
      struct Duration {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let headerObj: Header
      struct Header {
          let backObj: Back
          struct Back {
              let buttonObj: Button
              struct Button {
                  let accessibilityObj: Accessibility
                  struct Accessibility {
                    let hint: String
                  }
              }
          }
      }
      let muteObj: Mute
      struct Mute {
        let button: String
      }
      let onHoldObj: OnHold
      struct OnHold {
        let bottomText: String
        let icon: String
      }
      let operatorAvatarObj: OperatorAvatar
      struct OperatorAvatar {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let hint: String
            let label: String
          }
      }
      let operatorNameObj: OperatorName
      struct OperatorName {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let hint: String
          }
      }
      let operatorVideoObj: OperatorVideo
      struct OperatorVideo {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let speakerObj: Speaker
      struct Speaker {
        let button: String
      }
      let unmuteObj: Unmute
      struct Unmute {
        let button: String
      }
      let visitorVideoObj: VisitorVideo
      struct VisitorVideo {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let label: String
          }
      }
  }
  let callVisualizerObj: CallVisualizer
  struct CallVisualizer {
      let screenSharingObj: ScreenSharing
      struct ScreenSharing {
        let message: String
          let headerObj: Header
          struct Header {
            let title: String
          }
      }
      let visitorCodeObj: VisitorCode
      struct VisitorCode {
        let title: String
          let closeObj: Close
          struct Close {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let refreshObj: Refresh
          struct Refresh {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
                let label: String
              }
          }
          let titleObj: Title
          struct Title {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
  }
  let chatObj: Chat
  struct Chat {
    let attachFiles: String
    let unreadMessageDivider: String
      let attachmentObj: Attachment
      struct Attachment {
        let photoLibrary: String
        let takePhoto: String
        let unsupportedFile: String
          let messageObj: Message
          struct Message {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let choiceCardObj: ChoiceCard
      struct ChoiceCard {
        let placeholderMessage: String
          let buttonObj: Button
          struct Button {
              let disabledObj: Disabled
              struct Disabled {
                  let accessibilityObj: Accessibility
                  struct Accessibility {
                    let label: String
                  }
              }
          }
          let imageObj: Image
          struct Image {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let downloadObj: Download
      struct Download {
        let downloading: String
        let failed: String
      }
      let fileObj: File
      struct File {
          let infectedFileObj: InfectedFile
          struct InfectedFile {
            let error: String
          }
          let removeUploadObj: RemoveUpload
          struct RemoveUpload {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
          let sizeLimitObj: SizeLimit
          struct SizeLimit {
            let error: String
          }
          let uploadObj: Upload
          struct Upload {
            let failed: String
            let genericError: String
            let inProgress: String
            let networkError: String
            let scanning: String
            let success: String
          }
      }
      let inputObj: Input
      struct Input {
        let placeholder: String
      }
      let mediaUpgradeObj: MediaUpgrade
      struct MediaUpgrade {
          let audioObj: Audio
          struct Audio {
            let systemMessage: String
          }
          let videoObj: Video
          struct Video {
            let systemMessage: String
          }
      }
      let messageObj: Message
      struct Message {
        let delivered: String
        let startEngagementPlaceholder: String
          let unreadObj: Unread
          struct Unread {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let operatorAvatarObj: OperatorAvatar
      struct OperatorAvatar {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let operatorJoinedObj: OperatorJoined
      struct OperatorJoined {
        let systemMessage: String
      }
      let operatorNameObj: OperatorName
      struct OperatorName {
          let accessibilityObj: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let statusObj: Status
      struct Status {
        let typing: String
          let typingObj: Typing
          struct Typing {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
  }
  let engagementObj: Engagement
  struct Engagement {
    let defaultOperator: String
      let audioObj: Audio
      struct Audio {
        let title: String
      }
      let chatObj: Chat
      struct Chat {
        let title: String
      }
      let confirmObj: Confirm
      struct Confirm {
        let message: String
        let title: String
          let link1Obj: Link1
          struct Link1 {
            let text: String
            let url: String
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
          let link2Obj: Link2
          struct Link2 {
            let text: String
            let url: String
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let connectionScreenObj: ConnectionScreen
      struct ConnectionScreen {
        let connectWith: String
        let message: String
      }
      let endObj: End
      struct End {
        let message: String
          let confirmationObj: Confirmation
          struct Confirmation {
            let header: String
          }
      }
      let endedObj: Ended
      struct Ended {
        let header: String
        let message: String
      }
      let mediaUpgradeObj: MediaUpgrade
      struct MediaUpgrade {
        let offer: String
          let audioObj: Audio
          struct Audio {
            let info: String
          }
          let phoneObj: Phone
          struct Phone {
            let info: String
          }
      }
      let minimizeVideoObj: MinimizeVideo
      struct MinimizeVideo {
        let button: String
      }
      let phoneObj: Phone
      struct Phone {
        let title: String
      }
      let queueObj: Queue
      struct Queue {
        let transferring: String
          let closedObj: Closed
          struct Closed {
            let header: String
            let message: String
          }
          let leaveObj: Leave
          struct Leave {
            let header: String
            let message: String
          }
          let reconnectionObj: Reconnection
          struct Reconnection {
            let failed: String
          }
      }
      let queueWaitObj: QueueWait
      struct QueueWait {
        let message: String
      }
      let secureMessagingObj: SecureMessaging
      struct SecureMessaging {
        let title: String
      }
      let videoObj: Video
      struct Video {
        let title: String
      }
  }
  let errorObj: Error
  struct Error {
    let general: String
    let `internal`: String
    let unexpected: String
  }
  let generalObj: General
  struct General {
    let accept: String
    let allow: String
    let back: String
    let browse: String
    let cancel: String
    let close: String
    let comment: String
    let companyName: String
    let decline: String
    let download: String
    let end: String
    let message: String
    let no: String
    let ok: String
    let `open`: String
    let powered: String
    let refresh: String
    let retry: String
    let selected: String
    let send: String
    let sending: String
    let submit: String
    let thankYou: String
    let yes: String
    let you: String
      let closeObj: Close
      struct Close {
        let accessibility: String
      }
  }
  let gvaObj: Gva
  struct Gva {
      let unsupportedActionObj: UnsupportedAction
      struct UnsupportedAction {
        let error: String
      }
  }
  let iosObj: Ios
  struct Ios {
      let alertObj: Alert
      struct Alert {
          let cameraAccessObj: CameraAccess
          struct CameraAccess {
            let message: String
          }
          let mediaSourceObj: MediaSource
          struct MediaSource {
            let message: String
          }
          let microphoneAccessObj: MicrophoneAccess
          struct MicrophoneAccess {
            let message: String
          }
      }
      let engagementObj: Engagement
      struct Engagement {
          let connectionScreenObj: ConnectionScreen
          struct ConnectionScreen {
            let videoNotice: String
          }
      }
  }
  let liveObservationObj: LiveObservation
  struct LiveObservation {
      let indicatorObj: Indicator
      struct Indicator {
        let message: String
      }
  }
  let mediaUpgradeObj: MediaUpgrade
  struct MediaUpgrade {
      let audioObj: Audio
      struct Audio {
        let title: String
      }
      let videoObj: Video
      struct Video {
          let oneWayObj: OneWay
          struct OneWay {
            let title: String
          }
          let twoWayObj: TwoWay
          struct TwoWay {
            let title: String
          }
      }
  }
  let messageCenterObj: MessageCenter
  struct MessageCenter {
    let header: String
      let confirmationObj: Confirmation
      struct Confirmation {
        let subtitle: String
          let checkMessagesObj: CheckMessages
          struct CheckMessages {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
                let label: String
              }
          }
      }
      let notAuthenticatedObj: NotAuthenticated
      struct NotAuthenticated {
        let message: String
      }
      let unavailableObj: Unavailable
      struct Unavailable {
        let message: String
        let title: String
      }
      let welcomeObj: Welcome
      struct Welcome {
        let checkMessages: String
        let messageTitle: String
        let subtitle: String
        let title: String
          let checkMessagesObj: CheckMessages
          struct CheckMessages {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let filePickerObj: FilePicker
          struct FilePicker {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
                let label: String
              }
          }
          let messageInputObj: MessageInput
          struct MessageInput {
            let placeholder: String
          }
          let messageLengthObj: MessageLength
          struct MessageLength {
            let error: String
          }
          let sendObj: Send
          struct Send {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
  }
  let screenSharingObj: ScreenSharing
  struct ScreenSharing {
      let visitorScreenObj: VisitorScreen
      struct VisitorScreen {
          let disclaimerObj: Disclaimer
          struct Disclaimer {
            let info: String
            let title: String
          }
          let endObj: End
          struct End {
            let title: String
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
  }
  let surveyObj: Survey
  struct Survey {
      let actionObj: Action
      struct Action {
        let validationError: String
      }
      let questionObj: Question
      struct Question {
          let inputObj: Input
          struct Input {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let optionButtonObj: OptionButton
          struct OptionButton {
              let selectedObj: Selected
              struct Selected {
                  let accessibilityObj: Accessibility
                  struct Accessibility {
                    let label: String
                  }
              }
              let unselectedObj: Unselected
              struct Unselected {
                  let accessibilityObj: Accessibility
                  struct Accessibility {
                    let label: String
                  }
              }
          }
          let requiredObj: Required
          struct Required {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let validationObj: Validation
      struct Validation {
          let titleObj: Title
          struct Title {
              let accessibilityObj: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
  }
  let visitorCodeObj: VisitorCode
  struct VisitorCode {
    let failed: String
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces

// swiftlint:enable all
