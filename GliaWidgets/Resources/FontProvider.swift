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
        return UIFont(name: named, size: size) ?? .systemFont(ofSize: size)
    }

    private func loadFonts() {
        _ = fonts.first(where: { !loadFont(named: $0) })
    }

    private func loadFont(named name: String) -> Bool {
        let bundle = Bundle(for: BundleToken.self)

        guard
            let pathForResourceString = bundle.path(forResource: name, ofType: "ttf"),
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData),
            let fontRef = CGFont(dataProvider)
        else {
            print("Could not load font='\(name)'. Perhaps they are not inculded in the bundle?")
            return false
        }

        var errorRef: Unmanaged<CFError>?
        let registrationResult = CTFontManagerRegisterGraphicsFont(fontRef, &errorRef)

        if !registrationResult {
            print("Font='\(name)' has not been registered properly. Error='\(errorRef.debugDescription)'.")
            return false
        }

        return true
    }
}

private final class BundleToken {}
