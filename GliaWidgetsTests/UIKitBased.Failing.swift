@testable import GliaWidgets

extension UIKitBased.UIImage {
    static let failing = Self(
        imageWithContentsOfFileAtPath: { _ in
            fail("\(Self.self).imageWithContentsOfFileAtPath")
            return nil
        }
    )
}
