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

extension FoundationBased.OperationQueue {
    static func mock() -> Self {
        .init(
            setMaxConcurrentOperationCount: { _ in },
            getMaxConcurrentOperationCount: { .zero },
            addOperation: { _ in }
        )
    }
}

extension FoundationBased.Timer {
    static let mock = Self(invalidate: {})
}

extension FoundationBased.Timer.Providing {
    static let mock = Self(
        scheduledTimerWithTimeIntervalAndTarget: { _, _, _, _, _ in
            .mock
        },
        scheduledTimerWithTimeIntervalAndRepeats: { _, _, _ in
            .mock
        }
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

    // swiftlint:disable force_unwrapping
    static var incrementing: () -> UUID {
        var uuid = 0
        return {
            defer { uuid += 1 }
            return Self(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
        }
    }
    // swiftlint:enable force_unwrapping
}

extension URL {
    static let mock = Self(string: "https://mock.mock").unsafelyUnwrapped
    static let mockFilePath = Self(fileURLWithPath: "file://mock/mock")
}
#endif
