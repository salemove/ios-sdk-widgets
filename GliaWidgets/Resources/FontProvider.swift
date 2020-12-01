import UIKit

internal class FontProvider {
    static let shared = FontProvider()

    private var fonts: [String] {
        return [
            "Roboto-Regular",
            "Roboto-Bold",
            "Roboto-Medium"
        ]
    }

    init() {
        loadFonts()
    }

    func font(named: String, size: CGFloat) -> UIFont {
        // swiftlint:disable force_unwrapping
        return UIFont(name: named, size: size)!
    }

    private func loadFonts() {
        fonts.forEach({ loadFont(named: $0) })
    }

    private func loadFont(named name: String) {
        let bundle = Bundle(for: BundleToken.self)

        guard let pathForResourceString = bundle.path(forResource: name, ofType: "ttf"),
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData),
            let fontRef = CGFont(dataProvider) else {
                fatalError("Could not load fonts. Perhaps they are not inculded in the bundle?")
        }

        var errorRef: Unmanaged<CFError>?
        let registrationResult = CTFontManagerRegisterGraphicsFont(fontRef, &errorRef)

        if !registrationResult {
            fatalError("Could not load fonts")
        }
    }
}

private final class BundleToken {}
