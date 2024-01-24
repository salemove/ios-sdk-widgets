// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings


// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
struct L10nX {
  let alert: Alert
  struct Alert {
      let action: Action
      struct Action {
        let settings: String
      }
      let cameraAccess: CameraAccess
      struct CameraAccess {
        let error: String
      }
      let mediaSourceAccess: MediaSourceAccess
      struct MediaSourceAccess {
        let error: String
      }
      let microphoneAccess: MicrophoneAccess
      struct MicrophoneAccess {
        let error: String
      }
      let screenSharing: ScreenSharing
      struct ScreenSharing {
          let start: Start
          struct Start {
            let header: String
            let message: String
          }
          let stop: Stop
          struct Stop {
            let header: String
            let message: String
          }
      }
  }
  let call: Call
  struct Call {
      let bubble: Bubble
      struct Bubble {
          let accessibility: Accessibility
          struct Accessibility {
            let hint: String
            let label: String
          }
      }
      let buttons: Buttons
      struct Buttons {
          let chat: Chat
          struct Chat {
              let badgeValue: BadgeValue
              struct BadgeValue {
                  let multipleItems: MultipleItems
                  struct MultipleItems {
                      let accessibility: Accessibility
                      struct Accessibility {
                        let label: String
                      }
                  }
                  let singleItem: SingleItem
                  struct SingleItem {
                      let accessibility: Accessibility
                      struct Accessibility {
                        let label: String
                      }
                  }
              }
          }
      }
      let connect: Connect
      struct Connect {
          let firstText: FirstText
          struct FirstText {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let secondText: SecondText
          struct SecondText {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
      let duration: Duration
      struct Duration {
          let accessibility: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let header: Header
      struct Header {
          let back: Back
          struct Back {
              let button: Button
              struct Button {
                  let accessibility: Accessibility
                  struct Accessibility {
                    let hint: String
                  }
              }
          }
      }
      let mute: Mute
      struct Mute {
        let button: String
      }
      let onHold: OnHold
      struct OnHold {
        let bottomText: String
        let icon: String
      }
      let operatorAvatar: OperatorAvatar
      struct OperatorAvatar {
          let accessibility: Accessibility
          struct Accessibility {
            let hint: String
            let label: String
          }
      }
      let operatorName: OperatorName
      struct OperatorName {
          let accessibility: Accessibility
          struct Accessibility {
            let hint: String
          }
      }
      let operatorVideo: OperatorVideo
      struct OperatorVideo {
          let accessibility: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let speaker: Speaker
      struct Speaker {
        let button: String
      }
      let unmute: Unmute
      struct Unmute {
        let button: String
      }
      let visitorVideo: VisitorVideo
      struct VisitorVideo {
          let accessibility: Accessibility
          struct Accessibility {
            let label: String
          }
      }
  }
  let callVisualizer: CallVisualizer
  struct CallVisualizer {
      let screenSharing: ScreenSharing
      struct ScreenSharing {
        let message: String
          let header: Header
          struct Header {
            let title: String
          }
      }
      let visitorCode: VisitorCode
      struct VisitorCode {
        let title: String
          let close: Close
          struct Close {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let refresh: Refresh
          struct Refresh {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
                let label: String
              }
          }
          let title: Title
          struct Title {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
  }
  let chat: Chat
  struct Chat {
    let attachFiles: String
    let unreadMessageDivider: String
      let attachment: Attachment
      struct Attachment {
        let photoLibrary: String
        let takePhoto: String
        let unsupportedFile: String
          let message: Message
          struct Message {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let choiceCard: ChoiceCard
      struct ChoiceCard {
        let placeholderMessage: String
          let button: Button
          struct Button {
              let disabled: Disabled
              struct Disabled {
                  let accessibility: Accessibility
                  struct Accessibility {
                    let label: String
                  }
              }
          }
          let image: Image
          struct Image {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let download: Download
      struct Download {
        let downloading: String
        let failed: String
      }
      let file: File
      struct File {
          let infectedFile: InfectedFile
          struct InfectedFile {
            let error: String
          }
          let removeUpload: RemoveUpload
          struct RemoveUpload {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
          let sizeLimit: SizeLimit
          struct SizeLimit {
            let error: String
          }
          let upload: Upload
          struct Upload {
            let failed: String
            let genericError: String
            let inProgress: String
            let networkError: String
            let scanning: String
            let success: String
          }
      }
      let input: Input
      struct Input {
        let placeholder: String
      }
      let mediaUpgrade: MediaUpgrade
      struct MediaUpgrade {
          let audio: Audio
          struct Audio {
            let systemMessage: String
          }
          let video: Video
          struct Video {
            let systemMessage: String
          }
      }
      let message: Message
      struct Message {
        let delivered: String
        let startEngagementPlaceholder: String
          let unread: Unread
          struct Unread {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let operatorAvatar: OperatorAvatar
      struct OperatorAvatar {
          let accessibility: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let operatorJoined: OperatorJoined
      struct OperatorJoined {
        let systemMessage: String
      }
      let operatorName: OperatorName
      struct OperatorName {
          let accessibility: Accessibility
          struct Accessibility {
            let label: String
          }
      }
      let status: Status
      struct Status {
        let typing: String
          let typing: Typing
          struct Typing {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
  }
  let engagement: Engagement
  struct Engagement {
    let defaultOperator: String
      let audio: Audio
      struct Audio {
        let title: String
      }
      let chat: Chat
      struct Chat {
        let title: String
      }
      let confirm: Confirm
      struct Confirm {
        let message: String
        let title: String
          let link1: Link1
          struct Link1 {
            let text: String
            let url: String
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
          let link2: Link2
          struct Link2 {
            let text: String
            let url: String
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let connectionScreen: ConnectionScreen
      struct ConnectionScreen {
        let connectWith: String
        let message: String
      }
      let end: End
      struct End {
        let message: String
          let confirmation: Confirmation
          struct Confirmation {
            let header: String
          }
      }
      let ended: Ended
      struct Ended {
        let header: String
        let message: String
      }
      let mediaUpgrade: MediaUpgrade
      struct MediaUpgrade {
        let offer: String
          let audio: Audio
          struct Audio {
            let info: String
          }
          let phone: Phone
          struct Phone {
            let info: String
          }
      }
      let minimizeVideo: MinimizeVideo
      struct MinimizeVideo {
        let button: String
      }
      let phone: Phone
      struct Phone {
        let title: String
      }
      let queue: Queue
      struct Queue {
        let transferring: String
          let closed: Closed
          struct Closed {
            let header: String
            let message: String
          }
          let leave: Leave
          struct Leave {
            let header: String
            let message: String
          }
          let reconnection: Reconnection
          struct Reconnection {
            let failed: String
          }
      }
      let queueWait: QueueWait
      struct QueueWait {
        let message: String
      }
      let secureMessaging: SecureMessaging
      struct SecureMessaging {
        let title: String
      }
      let video: Video
      struct Video {
        let title: String
      }
  }
  let error: Error
  struct Error {
    let general: String
    let `internal`: String
    let unexpected: String
  }
  let general: General
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
      let close: Close
      struct Close {
        let accessibility: String
      }
  }
  let gva: Gva
  struct Gva {
      let unsupportedAction: UnsupportedAction
      struct UnsupportedAction {
        let error: String
      }
  }
  let ios: Ios
  struct Ios {
      let alert: Alert
      struct Alert {
          let cameraAccess: CameraAccess
          struct CameraAccess {
            let message: String
          }
          let mediaSource: MediaSource
          struct MediaSource {
            let message: String
          }
          let microphoneAccess: MicrophoneAccess
          struct MicrophoneAccess {
            let message: String
          }
      }
      let engagement: Engagement
      struct Engagement {
          let connectionScreen: ConnectionScreen
          struct ConnectionScreen {
            let videoNotice: String
          }
      }
  }
  let liveObservation: LiveObservation
  struct LiveObservation {
      let indicator: Indicator
      struct Indicator {
        let message: String
      }
  }
  let mediaUpgrade: MediaUpgrade
  struct MediaUpgrade {
      let audio: Audio
      struct Audio {
        let title: String
      }
      let video: Video
      struct Video {
          let oneWay: OneWay
          struct OneWay {
            let title: String
          }
          let twoWay: TwoWay
          struct TwoWay {
            let title: String
          }
      }
  }
  let messageCenter: MessageCenter
  struct MessageCenter {
    let header: String
      let confirmation: Confirmation
      struct Confirmation {
        let subtitle: String
          let checkMessages: CheckMessages
          struct CheckMessages {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
                let label: String
              }
          }
      }
      let notAuthenticated: NotAuthenticated
      struct NotAuthenticated {
        let message: String
      }
      let unavailable: Unavailable
      struct Unavailable {
        let message: String
        let title: String
      }
      let welcome: Welcome
      struct Welcome {
        let checkMessages: String
        let messageTitle: String
        let subtitle: String
        let title: String
          let checkMessages: CheckMessages
          struct CheckMessages {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let filePicker: FilePicker
          struct FilePicker {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
                let label: String
              }
          }
          let messageInput: MessageInput
          struct MessageInput {
            let placeholder: String
          }
          let messageLength: MessageLength
          struct MessageLength {
            let error: String
          }
          let send: Send
          struct Send {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
  }
  let screenSharing: ScreenSharing
  struct ScreenSharing {
      let visitorScreen: VisitorScreen
      struct VisitorScreen {
          let disclaimer: Disclaimer
          struct Disclaimer {
            let info: String
            let title: String
          }
          let end: End
          struct End {
            let title: String
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
      }
  }
  let survey: Survey
  struct Survey {
      let action: Action
      struct Action {
        let validationError: String
      }
      let question: Question
      struct Question {
          let input: Input
          struct Input {
              let accessibility: Accessibility
              struct Accessibility {
                let hint: String
              }
          }
          let optionButton: OptionButton
          struct OptionButton {
              let selected: Selected
              struct Selected {
                  let accessibility: Accessibility
                  struct Accessibility {
                    let label: String
                  }
              }
              let unselected: Unselected
              struct Unselected {
                  let accessibility: Accessibility
                  struct Accessibility {
                    let label: String
                  }
              }
          }
          let `required`: Required
          struct Required {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
      let validation: Validation
      struct Validation {
          let title: Title
          struct Title {
              let accessibility: Accessibility
              struct Accessibility {
                let label: String
              }
          }
      }
  }
  let visitorCode: VisitorCode
  struct VisitorCode {
    let failed: String
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces

// swiftlint:enable all
