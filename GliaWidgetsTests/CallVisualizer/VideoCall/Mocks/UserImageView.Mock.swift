#if DEBUG

import UIKit

extension CallVisualizer.VideoCallView.UserImageView.Props {
    static let mock = Self(
        style: .mock(),
        operatorImageVisible: false,
        placeHolderImage: .mock,
        operatorImageViewProps: .init())
}

#endif
