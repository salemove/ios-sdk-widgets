import Foundation

enum SecureChatModel<Chat, Transcript> {
    case chat(Chat)
    case transcript(Transcript)
}

protocol CommonEngagementModel: AnyObject {
    var engagementAction: EngagementViewModel.ActionCallback? { get set }
    var engagementDelegate: EngagementViewModel.DelegateCallback? { get set }
    func event(_ event: EngagementViewModel.Event)
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

extension SecureChatModel where Chat == ChatViewModel, Transcript == SecureConversations.TranscriptModel {
    typealias Action = SecureChatModel<Chat.Action, Transcript.Action>
    typealias ActionCallback = (Action) -> Void
    typealias DelegateEvent = SecureChatModel<Chat.DelegateEvent, Transcript.DelegateEvent>
    typealias DelegateCallback = (DelegateEvent) -> Void
    typealias Event = SecureChatModel<Chat.Event, Transcript.Event>

    var action: ActionCallback? {
        get {
            switch self {
            case let .chat(model):
                return model.action.map { callback in { action in
                        switch action {
                        case let .chat(chatAction):
                            callback(chatAction)
                        case .transcript:
                            break
                        }
                    }
                }
            case let .transcript(model):
                return model.action.map { callback in { action in
                        switch action {
                        case .chat:
                            break
                        case let .transcript(transcriptAction):
                            callback(transcriptAction)
                        }
                    }
                }
            }
        }

        set {
            switch self {
            case let .chat(model):
                model.action = newValue.map { callback in { action in
                        callback(.chat(action))
                    }
                }
            case let .transcript(model):
                model.action = newValue.map { callback in { action in
                        callback(.transcript(action))
                    }
                }
            }
        }
    }

    var delegate: DelegateCallback? {
        get {
            switch self {
            case let .chat(model):
                return model.delegate.map { callback in { action in
                        switch action {
                        case let .chat(chatAction):
                            callback(chatAction)
                        case .transcript:
                            break
                        }
                    }
                }
            case let .transcript(model):
                return model.delegate.map { callback in { delegateEvent in
                        switch delegateEvent {
                        case .chat:
                            break
                        case let .transcript(delegateEvent):
                            callback(delegateEvent)
                        }
                    }
                }
            }
        }

        set {
            switch self {
            case let .chat(model):
                model.delegate = newValue.map { callback in { delegateEvent in
                        callback(.chat(delegateEvent))
                    }
                }
            case let .transcript(model):
                model.delegate = newValue.map { callback in { delegateEvent in
                        callback(.transcript(delegateEvent))
                    }
                }
            }
        }
    }

    var numberOfSections: Int {
        switch self {
        case let .chat(model):
            return model.numberOfSections
        case let .transcript(model):
            return model.numberOfSections
        }
    }

    func event(_ event: Event) {
        switch (self, event) {
        case let (.chat(chatModel), .chat(chatEvent)):
            chatModel.event(chatEvent)
        case let (.transcript(transcriptModel), .transcript(transcriptEvent)):
            transcriptModel.event(transcriptEvent)
        case (.chat, .transcript), (.transcript, .chat):
            break
        }
    }

    func numberOfItems(in section: Int) -> Int {
        switch self {
        case let .chat(model):
            return model.numberOfItems(in: section)
        case let .transcript(model):
            return model.numberOfItems(in: section)
        }
    }

    func item(for row: Int, in section: Int) -> ChatItem {
        switch self {
        case let .chat(model):
            return model.item(for: row, in: section)
        case let .transcript(model):
            return model.item(for: row, in: section)
        }
    }
}

extension SecureConversations {
    final class TranscriptModel: CommonEngagementModel {
        typealias ActionCallback = (Action) -> Void
        typealias DelegateCallback = (DelegateEvent) -> Void
        enum Action {}
        enum DelegateEvent {}
        enum Event {
            // TODO: MOB-1863
        }

        var action: ActionCallback?
        var delegate: DelegateCallback?

        var engagementAction: EngagementViewModel.ActionCallback?
        var engagementDelegate: EngagementViewModel.DelegateCallback?

        var numberOfSections: Int {
            // TODO: MOB-1863
            .zero
        }

        func numberOfItems(in section: Int) -> Int {
            // TODO: MOB-1863
            .zero
        }

        func item(for row: Int, in section: Int) -> ChatItem {
            // TODO: MOB-1863
            fatalError("Unimplemnted")
        }

        func event(_ event: EngagementViewModel.Event) {
            // TODO: MOB-1863
        }

        func event(_ event: Event) {
            // TODO: MOB-1863
        }
    }
}

extension SecureConversations {
    typealias ChatWithTranscriptModel = SecureChatModel<ChatViewModel, TranscriptModel>
}
