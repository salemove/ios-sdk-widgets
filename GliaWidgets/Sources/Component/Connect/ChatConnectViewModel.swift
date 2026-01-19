import SwiftUI

extension ChatConnectViewHost {
    @MainActor
    final class Model: ObservableObject {
        @Published var state: EngagementState = .initial
        let connectStyle: ConnectStyle
        let imageCache: RemoteImageLoader.Cache

        init(
            connectStyle: ConnectStyle,
            imageCache: RemoteImageLoader.Cache
        ) {
            self.connectStyle = connectStyle
            self.imageCache = imageCache
        }
    }
}
