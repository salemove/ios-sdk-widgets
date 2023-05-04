import Foundation
@testable import GliaWidgets

extension SecureConversations.ConfirmationViewModel {
    static let mock = SecureConversations.ConfirmationViewModel(
        environment: .mock
    )
}

extension SecureConversations.ConfirmationViewModel.Environment {
    static let mock = SecureConversations.ConfirmationViewModel.Environment(
        confirmationStyle: Theme().secureConversationsConfirmation
    )
}
