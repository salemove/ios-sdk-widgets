import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension OpenTelemetry {
    struct Key: DependencyKey {
        static var live = OpenTelemetry()

        #if DEBUG
        static var test = OpenTelemetry()
        #endif
    }
}

extension DependencyContainer.Widgets {
    var openTelemetry: OpenTelemetry {
        get { self[OpenTelemetry.Key.self] }
        set { self[OpenTelemetry.Key.self] = newValue }
    }
}
