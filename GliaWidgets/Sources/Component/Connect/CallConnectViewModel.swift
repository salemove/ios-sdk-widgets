import SwiftUI

extension CallConnectViewHost {
    @MainActor
    final class Model: ObservableObject {
        @Published var state: EngagementState = .initial
        @Published var mode: CallView.Mode = .audio
        @Published var durationText: String?
        let imageCache: RemoteImageLoader.Cache
        let connectStyle: ConnectStyle
        let callStyle: CallStyle
        let durationHint: String?

        init(
            connectStyle: ConnectStyle,
            callStyle: CallStyle,
            durationHint: String?,
            imageCache: RemoteImageLoader.Cache
        ) {
            self.connectStyle = connectStyle
            self.callStyle = callStyle
            self.durationHint = durationHint
            self.imageCache = imageCache
            self.state = .initial
            self.mode = .audio
        }
    }
}
