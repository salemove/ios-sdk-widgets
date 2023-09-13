import Foundation
import Combine

extension FoundationBased.FileManager {
    static let live = Self(
        urlsForDirectoryInDomainMask: FileManager.default.urls(for:in:),
        fileExistsAtPath: FileManager.default.fileExists(atPath:),
        createDirectoryAtUrlWithIntermediateDirectories: FileManager.default.createDirectory(at:withIntermediateDirectories:attributes:),
        removeItemAtUrl: FileManager.default.removeItem(at:),
        copyItemAtPath: FileManager.default.copyItem(atPath:toPath:),
        contentsOfDirectoryAtPath: FileManager.default.contentsOfDirectory(atPath:),
        attributesOfItemAtPath: FileManager.default.attributesOfItem(atPath:),
        removeItemAtPath: FileManager.default.removeItem(atPath:)
    )
}

extension FoundationBased.Data {
    static let live = Self(
        writeDataToUrl: { data, url in try data.write(to: url) },
        dataWithContentsOfFileUrl: { url in try Foundation.Data(contentsOf: url) }
    )
}

extension FoundationBased.OperationQueue {
    static func live() -> Self {
        let operationQueue = OperationQueue()
        return .init(
            setMaxConcurrentOperationCount: { operationQueue.maxConcurrentOperationCount = $0 },
            getMaxConcurrentOperationCount: { operationQueue.maxConcurrentOperationCount },
            addOperation: operationQueue.addOperation(_:)
        )
    }
}

extension FoundationBased.Timer.Providing {
    static let live: Self = {
        let provider = Self(
            scheduledTimerWithTimeIntervalAndTarget: { timeInterval, target, selector, userInfo, repeats in
                let liveTimer = Foundation.Timer
                    .scheduledTimer(
                        timeInterval: timeInterval,
                        target: target,
                        selector: selector,
                        userInfo: userInfo,
                        repeats: repeats
                    )
                return .init(invalidate: liveTimer.invalidate)
            },
            scheduledTimerWithTimeIntervalAndRepeats: { timeInterval, repeats, block in
                let liveTimer = Foundation.Timer
                    .scheduledTimer(
                        withTimeInterval: timeInterval,
                        repeats: repeats,
                        block: { live in
                            block(.init(invalidate: live.invalidate))
                        }
                    )
                return .init(invalidate: liveTimer.invalidate)
            }
        )
        return provider
    }()
}

extension FoundationBased.NotificationCenter {
    static let live = Self(
        addObserverClosure: NotificationCenter.default.addObserver,
        removeObserverClosure: NotificationCenter.default.removeObserver,
        removeObserverWithNameAndObject: NotificationCenter.default.removeObserver,
        publisherForNotification: { NotificationCenter.default.publisher(for: $0).eraseToAnyPublisher() }
    )
}
