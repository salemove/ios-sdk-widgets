import Foundation

extension L10n.Call {
    static let onHold = L10n.Call.OnHold.topText

    struct Bubble {
        struct Accessibility {
            static let hint = L10n.Call.Accessibility.Bubble.hint
            static let label = L10n.Call.Accessibility.Bubble.label
        }
    }

    struct Button {
        static let mute = L10n.Call.Buttons.Mute.Inactive.title
        static let speaker = L10n.Call.Buttons.Speaker.title
        static let unmute = L10n.Call.Buttons.Mute.Active.title
    }

    struct Header {
        struct CloseButton {
            struct Accessibility {
                static let hint = L10n.Call.Accessibility.Header.BackButton.hint
            }
        }
    }

    struct OperatorName {
        struct Accessibility {
            static let hint = L10n.Call.Accessibility.OperatorName.hint
        }
    }
}

extension L10n.Call.Buttons.Chat {
    struct BadgeValue {
        struct MultipleItems {
            struct Accessibility {
                static let label = L10n.Call.Accessibility.Buttons.Chat.BadgeValue.multipleItems
            }
        }

        struct SingleItem {
            struct Accessibility {
                static let label = L10n.Call.Accessibility.Buttons.Chat.BadgeValue.singleItem
            }
        }
    }
}

extension L10n.Call.Connect {
    struct FirstText {
        struct Accessibility {
            static let hint = L10n.Call.Accessibility.Connect.Queue.FirstText.hint
        }
    }

    struct SecondText {
        struct Accessibility {
            static let hint = L10n.Call.Accessibility.Connect.Queue.SecondText.hint
        }
    }
}

extension L10n.Call.Operator {
    struct Avatar {
        struct Accessibility {
            static let label = L10n.Call.Accessibility.Operator.Avatar.label
            static let hint = L10n.Call.Accessibility.Operator.Avatar.hint
        }
    }
}

extension L10n.Call.Video {
    struct Operator {
        struct Accessiblity {
            static let label = L10n.Call.Accessibility.Video.Operator.label
        }
    }

    struct Visitor {
        struct Accessibility {
            static let label = L10n.Call.Accessibility.Video.Visitor.label
        }
    }
}

extension L10n.CallVisualizer.ScreenSharing {
    struct Message {
        struct Accessibility {
            static let hint = L10n.CallVisualizer.ScreenSharing.Accessibility.messageHint
        }
    }
}

extension L10n.CallVisualizer.VisitorCode {
    static let title = L10n.CallVisualizer.VisitorCode.Title.standard

    struct Close {
        struct Accessibility {
            static let hint = L10n.CallVisualizer.VisitorCode.Accessibility.closeHint
            static let label = L10n.CallVisualizer.VisitorCode.Accessibility.closeLabel
        }
    }

    struct Refresh {
        struct Accessibility {
            static let hint = L10n.CallVisualizer.VisitorCode.Accessibility.refreshHint
            static let label = L10n.CallVisualizer.VisitorCode.Accessibility.refreshLabel
        }
    }
}

extension L10n.CallVisualizer.VisitorCode.Title {
    struct Accessibility {
        static let label = L10n.CallVisualizer.VisitorCode.Accessibility.titleHint
    }
}

extension L10n.Chat {
    static let attachFiles = L10n.Chat.Accessibility.PickMedia.PickAttachmentButton.label
    static let operatorJoined = L10n.Chat.Connect.Connected.secondText
    static let unreadMessageDivider = L10n.Chat.SecureTranscript.unreadMessageDividerTitle

    struct Attachment {
        static let photoLibrary = L10n.Chat.PickMedia.photo
        static let takePhoto = L10n.Chat.PickMedia.takePhoto

        struct Upload {
            static let unsupportedFile = L10n.Chat.Upload.Error.unsupportedFileType
        }
    }

    struct Operator {
        struct Avatar {
            struct Accessibility {
                static let label = L10n.Chat.Accessibility.Operator.Avatar.label
            }
        }

        struct Name {
            struct Accessibility {
                static let label = L10n.Chat.Accessibility.Connect.Queue.FirstText.hint
            }
        }
    }
}

extension L10n.Chat.File {
    static let infectedError = L10n.Chat.Upload.Error.safetyCheckFailed
    static let tooLargeError = L10n.Chat.Upload.Error.fileTooBig
}

extension L10n.Chat.File.Upload {
    static let failed = L10n.Chat.Upload.Error.generic
    static let inProgress = L10n.Chat.Upload.uploading
    static let success = L10n.Chat.Upload.uploaded
}

extension L10n.Chat.Input {
    static let placeholder = L10n.Chat.Message.enterMessagePlaceholder
}

extension L10n.Chat.Upload {
    struct Remove {
        struct Accessibility {
            static let label = L10n.Chat.Accessibility.Upload.RemoveUpload.label
        }
    }
}

extension L10n.Chat.Message {
    struct Unread {
        struct Accessibility {
            static let label = L10n.Chat.Accessibility.Message.UnreadMessagesIndicator.label
        }
    }
}

extension L10n {
    struct Engagement {
        static let defaultOperatorName = L10n.operator
        static let minimizeVideoButton = L10n.Call.Buttons.Minimize.title
        static let offerUpgrade = L10n.Alert.MediaUpgrade.title

        struct Connect {
            static let placeholder = L10n.Call.Connect.Queue.secondText
            static let with = L10n.Call.Connect.Connecting.firstText
        }

        struct End {
            static let message = L10n.Alert.EndEngagement.message

            struct Confirmation {
                static let header = L10n.Alert.EndEngagement.title
            }
        }

        struct Ended {
            static let header = L10n.Alert.OperatorEndedEngagement.title
            static let message = L10n.Alert.OperatorEndedEngagement.message
        }

        struct QueueClosed {
            static let header = L10n.Alert.OperatorsUnavailable.title
            static let message = L10n.Alert.OperatorsUnavailable.message
        }

        struct QueueLeave {
            static let header = L10n.Alert.LeaveQueue.title
            static let message = L10n.Alert.LeaveQueue.message
        }

        struct QueueReconnectionFailed {
            static let tryAgain = L10n.Alert.Unexpected.message
        }

        struct QueueTransferring {
            static let message = L10n.Chat.Connect.Transferring.firstText
        }

        struct QueueWait {
            static let message = L10n.Call.bottomText
        }

        struct SecureMessaging {
            static let title = L10n.MessageCenter.Welcome.header
        }
    }

    struct Media {
        struct Audio {
            static let name = L10n.Call.Audio.title
        }

        struct Phone {
            static let name = L10n.Alert.MediaUpgrade.Phone.title
        }

        struct Text {
            static let name = L10n.Chat.title
        }

        struct Video {
            static let name = L10n.Call.Video.title
        }
    }
}

extension L10n.MessageCenter {
    static let checkMessages = L10n.MessageCenter.Welcome.checkMessages
    static let header = L10n.MessageCenter.Welcome.header

    struct NotAuthenticated {
        static let message = L10n.Alert.UnavailableMessageCenter.notAuthenticatedMessage
    }

    struct Unavailable {
        static let message = L10n.Alert.UnavailableMessageCenter.message
        static let title = L10n.Alert.UnavailableMessageCenter.title
    }
}

extension L10n.MessageCenter.Welcome {
    struct CheckMessages {
        struct Accessibility {
            static let hint = L10n.MessageCenter.Welcome.Accessibility.checkMessagesHint
        }
    }

    struct FilePicker {
        struct Acccessibility {
            static let hint = L10n.MessageCenter.Welcome.Accessibility.filePickerHint
            static let label = L10n.MessageCenter.Welcome.Accessibility.filePickerLabel
        }
    }

    struct MessageTextView {
        static let placeholder = L10n.MessageCenter.Welcome.messageTextViewNormal
    }

    struct Send {
        struct Accessibility {
            static let hint = L10n.MessageCenter.Welcome.Accessibility.sendHint
        }
    }
}
extension L10n.MessageCenter.Confirmation {
    struct CheckMessages {
        struct Accessibility {
            static let hint = L10n.MessageCenter.Welcome.Accessibility.checkMessagesHint
            static let label = L10n.MessageCenter.Welcome.Accessibility.checkMessagesLabel
        }
    }
}

extension L10n {
    struct ScreenSharing {
        struct VisitorScreen {
            static let end = L10n.CallVisualizer.ScreenSharing.Button.title
        }
    }
}

extension L10n.Survey.Question {
    struct OptionButton {
        struct Selected {
            struct Accessibility {
                static let label = L10n.Survey.Accessibility.Question.OptionButton.Selected.label
            }
        }

        struct Unselected {
            struct Accessibility {
                static let label = L10n.Survey.Accessibility.Question.OptionButton.Unselected.label
            }
        }
    }

    struct TextField {
        struct Accessibility {
            static let hint = L10n.Survey.Accessibility.Question.TextField.hint
        }
    }
}

extension L10n.Survey.Question.Title {
    struct Accessibility {
        static let label = L10n.Survey.Accessibility.Question.Title.value
    }
}

extension L10n.Survey {
    struct Validation {
        struct Title {
            struct Accessibility {
                static let label = L10n.Survey.Accessibility.Validation.Title.label
            }
        }
    }
}

extension L10n {
    struct Upgrade {
        struct Audio {
            static let title = L10n.Alert.AudioUpgrade.title
        }

        struct Video {
            struct OneWay {
                static let title = L10n.Alert.VideoUpgrade.OneWay.title
            }

            struct TwoWay {
                static let title = L10n.Alert.VideoUpgrade.TwoWay.title
            }
        }
    }
}

extension L10n {
    struct VisitorCode {
        static let failed = L10n.CallVisualizer.VisitorCode.Title.error
    }
}
