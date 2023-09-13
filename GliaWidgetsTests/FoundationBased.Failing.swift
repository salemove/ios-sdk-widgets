@testable import GliaWidgets
import Combine

extension FoundationBased.FileManager {
    static let failing = Self(
        urlsForDirectoryInDomainMask: { _, _ in
            fail("\(Self.self).urlsForDirectoryInDomainMask")
            return []
        },
        fileExistsAtPath: { _ in
            fail("\(Self.self).fileExistsAtPath")
            return false
        },
        createDirectoryAtUrlWithIntermediateDirectories: { _, _, _ in
            fail("\(Self.self).createDirectoryAtUrlWithIntermediateDirectories")
        },
        removeItemAtUrl: { _ in
            fail("\(Self.self).removeItemAtUrl")
        },
        copyItemAtPath: { _, _ in
            fail("\(Self.self).copyItemAtPath")
        },
        contentsOfDirectoryAtPath: { _ in
            fail("\(Self.self).contentsOfDirectoryAtPath")
            return []
        },
        attributesOfItemAtPath: { _ in
            fail("\(Self.self).attributesOfItemAtPath")
            return [:]
        },
        removeItemAtPath: { _ in
            fail("\(Self.self).removeItemAtPath")
        }
    )
}

extension FoundationBased.Data {
    static let failing = Self(
        writeDataToUrl: { _, _ in
            fail("\(Self.self).writeDataToUrl")
        },
        dataWithContentsOfFileUrl: { _ in
            fail("\(Self.self).dataWithContentsOfFileUrl")
            return .mock
        }
    )
}

extension FoundationBased.OperationQueue {
    static let failing = Self(
        setMaxConcurrentOperationCount: { _ in
            fail("\(Self.self).setMaxConcurrentOperationCount")
        },
        getMaxConcurrentOperationCount: {
            fail("\(Self.self).getMaxConcurrentOperationCount")
            return .zero
        },
        addOperation: { _ in
            fail("\(Self.self).addOperation")
        }
    )
}

extension FoundationBased.Timer {
    static let failing = Self(
        invalidate: { fail("\(Self.self).invalidate") }
    )
}

extension FoundationBased.Timer.Providing {
    static let failing = Self(
        scheduledTimerWithTimeIntervalAndTarget: { _, _, _, _, _ in
            fail("\(Self.self).scheduledTimerWithTimeIntervalAndTarget")
            return .failing
        },
        scheduledTimerWithTimeIntervalAndRepeats: { _, _, _ in
            fail("\(Self.self).scheduledTimerWithTimeIntervalAndRepeats")
            return .failing
        }
    )
}

extension FoundationBased.NotificationCenter {
    static let failing = Self.init(
        addObserverClosure: { _, _, _, _ in
            fail("\(Self.self).addObserverClosure")
        },
        removeObserverClosure: { _ in
            fail("\(Self.self).removeObserverClosure")
        },
        removeObserverWithNameAndObject: {_, _, _ in
            fail("\(Self.self).removeObserverWithNameAndObject")
        },
        publisherForNotification: { _ in
            fail("\(Self.self).publisherForNotification")
            return Empty<Notification, Never>().eraseToAnyPublisher()
        }
    )
}
