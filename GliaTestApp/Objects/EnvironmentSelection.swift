import Foundation
import GliaWidgets

enum EnvironmentSelection: String, Hashable, CaseIterable {
    case beta
    case us
    case eu
    case custom

    var gliaEnvironment: GliaEnvironment {
        switch self {
        case .beta: return .beta
        case .us: return .usa
        case .eu: return .europe
        case .custom: return .custom(URL(string: "https://")!)
        }
    }

    init(from environment: GliaEnvironment) {
        switch environment {
        case .beta: self = .beta
        case .usa: self = .us
        case .europe: self = .eu
        case .custom: self = .custom
        @unknown default: self = .beta
        }
    }
}
