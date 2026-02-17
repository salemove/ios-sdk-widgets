#if DEBUG

import Foundation

extension CallVisualizer.VideoCallView.ConnectView.Props {
    static let mock = Self(
        operatorViewProps: .mock,
        statusViewProps: .init(),
        state: .connected(name: "", imageUrl: ""),
        transition: .show(animation: true)
    )
}

#endif
