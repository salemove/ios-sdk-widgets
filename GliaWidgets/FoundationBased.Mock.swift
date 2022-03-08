#if DEBUG
import Foundation

extension FoundationBased.FileManager {
    static let mock = Self(
        urlsForDirectoryInDomainMask: { _, _ in [] },
        fileExistsAtPath: { _ in false },
        createDirectoryAtUrlWithIntermediateDirectories: { _, _, _ in },
        removeItemAtUrl: { _ in },
        copyItemAtPath: { _, _ in },
        contentsOfDirectoryAtPath: { _ in [] },
        attributesOfItemAtPath: { _ in [:] },
        removeItemAtPath: { _ in }
    )
}

extension FoundationBased.Data {
    static let mock = Self(
        writeDataToUrl: { _, _ in },
        dataWithContentsOfFileUrl: { _ in .mock }
    )
}

// MARK: - Foundation
extension Foundation.Date {
    static let mock = Self(timeIntervalSince1970: .zero)
}

extension Foundation.Data {
    static let mock = Self()
}

extension UUID {
    static let mock = Self(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef").unsafelyUnwrapped
}

extension URL {
    static let mock = Self(string: "https://mock.mock").unsafelyUnwrapped
    static let mockFilePath = Self(fileURLWithPath: "file://mock/mock")
}
#endif
