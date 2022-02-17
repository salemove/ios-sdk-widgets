import Foundation
@testable import GliaWidgets

extension CoreSdkClient.VisitorContext {

    static func mock(url: String = "www.glia.com") -> CoreSdkClient.VisitorContext {
        .init(type: .page, url: url)
    }
}

extension CoreSdkClient.Salemove.Configuration {

    static func mock(
        siteId: String = "mocked-id",
        region: CoreSdkClient.Salemove.Region = .us,
        authMethod: CoreSdkClient.Salemove.AuthorizationMethod = .appToken("mocked-app-token")
    ) -> CoreSdkClient.Salemove.Configuration {
        try! CoreSdkClient.Salemove.Configuration(
            siteId: siteId,
            region: region,
            authorizingMethod: authMethod
        )
    }
}
