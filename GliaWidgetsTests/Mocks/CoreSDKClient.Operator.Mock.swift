import Foundation
import GliaCoreSDK
@testable import GliaWidgets

extension CoreSdkClient.Operator {
    static func mock(
        id: String = "mockId",
        name: String = "Mock Operator",
        picture: GliaCoreSDK.OperatorPicture? = nil,
        availableMedia: [CoreSdkClient.MediaType]? = [.text, .audio, .video]
    ) -> CoreSdkClient.Operator {
        CoreSdkClient.Operator(
            id: id,
            name: name,
            picture: picture,
            availableMedia: availableMedia
        )
    }
}
