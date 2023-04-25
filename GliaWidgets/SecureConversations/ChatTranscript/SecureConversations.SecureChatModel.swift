import Foundation

enum SecureChatModel<Chat, Transcript> {
    case chat(Chat)
    case transcript(Transcript)
}

extension SecureChatModel where Chat: CommonEngagementModel, Transcript: CommonEngagementModel {
    var engagementModel: CommonEngagementModel {
        switch self {
        case let .chat(model):
            return model
        case let .transcript(model):
            return  model
        }
    }

    var engagementDelegate: EngagementViewModel.DelegateCallback? {
        get {
            engagementModel.engagementDelegate
        }

        set {
            engagementModel.engagementDelegate = newValue
        }
    }

    var engagementAction: EngagementViewModel.ActionCallback? {
        get {
            engagementModel.engagementAction
        }

        set {
            engagementModel.engagementAction = newValue
        }
    }

    func event(_ event: EngagementViewModel.Event) {
        engagementModel.event(event)
    }
}
