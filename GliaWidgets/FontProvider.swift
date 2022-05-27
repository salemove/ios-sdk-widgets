import UIKit

internal class FontProvider {
    static let shared = FontProvider()

    private let fonts: [FontName] = [
        .robotoRegular,
        .robotoBold,
        .robotoMedium
    ]
    private let bundleManaging: BundleManaging

    init(bundleManaging: BundleManaging = .live) {
        self.bundleManaging = bundleManaging
        loadFonts()
    }

    func font(named: String, size: CGFloat) -> UIFont {
        return UIFont(name: named, size: size) ?? .systemFont(ofSize: size)
    }

    /// Optionally provides font with name and size.
    /// - Parameters:
    ///   - named: Font name.
    ///   - size: Font size,
    /// - Returns: Font instance of specified name and size or `nil`.
    func optionalFont(named: String, size: CGFloat) -> UIFont? {
        return UIFont(name: named, size: size)
    }

    private func loadFonts() {
        _ = fonts.first(where: { !loadFont(named: $0.rawValue) })
    }

    private func loadFont(named name: String) -> Bool {
        guard
            let pathForResourceString = bundleManaging.current().path(forResource: name, ofType: "ttf"),
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

extension FontProvider {
    enum FontName: String {
        case robotoRegular = "Roboto-Regular"
        case robotoMedium = "Roboto-Medium"
        case robotoBold = "Roboto-Bold"
    }

    func font(named: FontName, size: CGFloat) -> UIFont {
        return font(named: named.rawValue, size: size)
    }
}
