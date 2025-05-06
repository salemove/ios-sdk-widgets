import Foundation
import GliaCoreSDK

public enum QueueStatus: Decodable, Equatable, Hashable {
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
