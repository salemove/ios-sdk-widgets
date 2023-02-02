@testable import GliaWidgets

extension UIKitBased.UIImage {
    static let failing = Self(
        imageWithContentsOfFileAtPath: { _ in
            fail("\(Self.self).imageWithContentsOfFileAtPath")
            return nil
        }
    )
}

extension UIKitBased.UIApplication {
    static let failing = Self(
        open: { _ in
            fail("\(Self.self).open")
        },
        canOpenURL: { _ in
            fail("\(Self.self).canOpenURL")
            return false
        },
        preferredContentSizeCategory: {
            fail("\(Self.self).preferredContentSizeCategory")
            return .unspecified
        },
        shared: { fail("\(Self.self).shared"); return .init() }
    )
}
