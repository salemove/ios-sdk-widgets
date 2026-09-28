import Foundation
@_spi(GliaWidgets) internal import GliaCoreSDK

extension MediaPickerController {
    struct Environment {
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}
