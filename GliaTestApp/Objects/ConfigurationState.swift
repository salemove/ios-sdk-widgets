import SwiftUI

enum ConfigurationState: Equatable {
    case idle
    case loading
    case configured
    case error(String)
}
