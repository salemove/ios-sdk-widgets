import UIKit
import Combine

protocol ApplicationVisibilityTracker: AnyObject {
    func isAppVisiblePublisher(
        for applicationState: UIApplication.State,
        notificationCenter: FoundationBased.NotificationCenter,
        resumeToForegroundDelay: DispatchQueue.SchedulerTimeType.Stride,
        delayScheduler: AnyScheduler
    ) -> AnyPublisher<Void, Never>

    func isViewVisiblePublisher(
        for applicationState: UIApplication.State,
        notificationCenter: FoundationBased.NotificationCenter,
        isViewVisiblePublisher: AnyPublisher<Bool, Never>,
        resumeToForegroundDelay: DispatchQueue.SchedulerTimeType.Stride,
        delayScheduler: AnyScheduler
    ) -> AnyPublisher<Void, Never>
}

extension ApplicationVisibilityTracker {
    func isAppVisiblePublisher(
        for applicationState: UIApplication.State,
        notificationCenter: FoundationBased.NotificationCenter,
        resumeToForegroundDelay: DispatchQueue.SchedulerTimeType.Stride,
        delayScheduler: AnyScheduler
    ) -> AnyPublisher<Void, Never> {
        return isViewVisiblePublisher(
            for: applicationState,
            notificationCenter: notificationCenter,
            isViewVisiblePublisher: Just(true).eraseToAnyPublisher(),
            resumeToForegroundDelay: resumeToForegroundDelay,
            delayScheduler: delayScheduler
        )
    }

    func isViewVisiblePublisher(
        for applicationState: UIApplication.State,
        notificationCenter: FoundationBased.NotificationCenter,
        isViewVisiblePublisher: AnyPublisher<Bool, Never>,
        resumeToForegroundDelay: DispatchQueue.SchedulerTimeType.Stride,
        delayScheduler: AnyScheduler
    ) -> AnyPublisher<Void, Never> {
        return Publishers.Merge3(
            Just(applicationState == .active),
            notificationCenter
                .publisherForNotification(UIApplication.willEnterForegroundNotification)
                .map { _ in true },
            notificationCenter
                .publisherForNotification(UIApplication.didEnterBackgroundNotification)
                .map { _ in false }
        )
            .combineLatest(isViewVisiblePublisher)
            .map { isApplicationForeground, isViewVisible in
                return isApplicationForeground && isViewVisible
            }
            .removeDuplicates()
            .map {
                if $0 {
                    return Just(true)
                        .delay(for: resumeToForegroundDelay, scheduler: delayScheduler)
                        .eraseToAnyPublisher()
                } else {
                    return Just(false)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .filter { $0 }
            .first()
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
