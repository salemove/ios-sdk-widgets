import Foundation
import GliaCoreSDK

public enum QueueStatus: Decodable, Equatable, Hashable, RawRepresentable {
    /// Visitor can enqueue
    case open
    /// Visitor cannot enqueue because the Queue is closed
    case closed
    /// Visitor cannot enqueue because the Queue reached its max capacity
    case full
    /// Visitor cannot enqueue because the Queue is unstaffed
    case unstaffed
    /// Visitor should not enqueue because the Queue state is not supported
    case unknown(String)

    public init?(rawValue: String) {
        switch rawValue {
        case Self.open.rawValue:
            self = .open
        case Self.closed.rawValue:
            self = .closed
        case Self.full.rawValue:
            self = .full
        case Self.unstaffed.rawValue:
            self = .unstaffed
        default:
            self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .open: return "opened"
        case .closed: return "closed"
        case .full: return "full"
        case .unstaffed: return "unstaffed"
        case let .unknown(value): return value
        }
    }

    public init(coreStatus: GliaCoreSDK.QueueStatus) {
        switch coreStatus {
        case .open:
          self = .open
        case .closed:
          self = .closed
        case .full:
          self = .full
        case .unstaffed:
          self = .unstaffed
        case .unknown(let raw):
          self = .unknown(raw)
        @unknown default:
            self = .unknown(coreStatus.rawValue)
        }
      }
}
