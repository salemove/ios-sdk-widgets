@testable import GliaWidgets

extension ImageView.Cache {
    static let failing = Self.init(
        setImageForKey: { _, _ in
            fail("\(Self.self).setImageForKey")
        },
        getImageForKey: { _ in
            fail("\(Self.self).getImageForKey")
            return nil
        }
    )
}
