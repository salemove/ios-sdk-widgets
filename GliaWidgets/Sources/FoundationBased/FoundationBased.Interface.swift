import Foundation

enum FoundationBased {
    struct FileManager {
        var urlsForDirectoryInDomainMask: (
            _ forDirectory: Foundation.FileManager.SearchPathDirectory,
            _ inDomainMask: Foundation.FileManager.SearchPathDomainMask
        ) -> [URL]

        var fileExistsAtPath: (_ atPath: String) -> Bool

        var createDirectoryAtUrlWithIntermediateDirectories: (
            _ atURL: URL,
            _ withIntermediateDirectories: Bool,
            _ attributes: [FileAttributeKey: Any]?
        ) throws -> Void

        var removeItemAtUrl: (_ atURL: URL) throws -> Void

        var copyItemAtPath: (
            _ atPath: String,
            _ toPath: String
        ) throws -> Void

        var contentsOfDirectoryAtPath: (_ atPath: String) throws -> [String]

        var attributesOfItemAtPath: (_ atPath: String) throws -> [FileAttributeKey: Any]

        var removeItemAtPath: (_ atPath: String) throws -> Void
    }

    struct Data {
        var writeDataToUrl: (
            _ data: Foundation.Data,
            _ toUrl: URL
        ) throws -> Void

        var dataWithContentsOfFileUrl: (
            _ contentsOfUrl: URL
        ) throws -> Foundation.Data
    }

    struct OperationQueue {
        var setMaxConcurrentOperationCount: (Int) -> Void
        var getMaxConcurrentOperationCount: () -> Int
        var addOperation: (_ block: @escaping () -> Void) -> Void
    }

    struct Timer {
        struct Providing {
            var scheduledTimerWithTimeIntervalAndTarget: (
                _ timeInterval: TimeInterval,
                _ target: Any,
                _ selector: Selector,
                _ userInfo: Any?,
                _ repeats: Bool
            ) -> Timer

            var scheduledTimerWithTimeIntervalAndRepeats: (
                _ interval: TimeInterval,
                _ repeats: Bool,
                _ block: @escaping (Timer) -> Void
            ) -> Timer
        }

        var invalidate: () -> Void
    }

    struct NotificationCenter {
        var addObserverClosure: (
            _ observer: Any,
            _ selector: Selector,
            _ name: NSNotification.Name?,
            _ object: Any?)
        -> Void

        var removeObserverClosure: (Any) -> Void
        var removeObserverWithNameAndObject: (
            _ observer: Any,
            _ name: NSNotification.Name?,
            _ object: Any?)
        -> Void

        func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
            addObserverClosure(observer, aSelector, aName, anObject)
        }

        func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
            removeObserverWithNameAndObject(observer, aName, anObject)
        }

        func removeObserver(_ observer: Any) {
            removeObserverClosure(observer)
        }
    }
}

extension FoundationBased.Timer.Providing {
    // Because `createScheduledTimerWithTimeInterval` takes 5
    // arguments, it makes sense to use some boilerplate
    // to restore usability by using similar interface
    // as in original `Foundation.Timer`
    func scheduledTimer(
        timeInterval ti: TimeInterval,
        target aTarget: Any,
        selector aSelector: Selector,
        userInfo: Any?,
        repeats yesOrNo: Bool) -> FoundationBased.Timer {
            scheduledTimerWithTimeIntervalAndTarget(
                ti,
                aTarget,
                aSelector,
                userInfo,
                yesOrNo
            )
    }

    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (FoundationBased.Timer) -> Void) -> FoundationBased.Timer {
        scheduledTimerWithTimeIntervalAndRepeats(
            interval,
            repeats,
            block
        )
    }
}
