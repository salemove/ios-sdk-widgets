import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension MediaPickerController {
    struct Environment {
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }
}
