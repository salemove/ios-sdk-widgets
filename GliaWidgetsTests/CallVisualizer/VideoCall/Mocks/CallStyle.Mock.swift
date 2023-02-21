#if DEBUG

import UIKit

extension CallStyle {
    static func mock() -> CallStyle {
        return Theme().callStyle
    }
}

#endif
