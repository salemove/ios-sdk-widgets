import Foundation
import GliaCoreSDK

/// Namespace for all secure conversations functionality
public struct SecureConversations {
    let environment: Environment

    /// Gets the count of unread messages sent through secure conversations.
    ///
    /// This count will increase if an operator sends a message and the visitor hasn't marked them as read yet.
    ///
    /// - Parameter completion: A callback that will return a `Result` with the number of unread
    /// secure conversation messages on success, or `Swift.Error` on failure.
    public func getUnreadMessageCount(_ callback: @escaping (Result<Int, Error>) -> Void) {
        Task {
            do {
                let unreadMessageCount = try await getUnreadMessageCount()
                callback(.success(unreadMessageCount))
            } catch {
                callback(.failure(error))
            }
        }
    }

    /// Observes the count of unread messages sent through secure conversations.
    ///
    /// This count will increase if an operator sends a message and the visitor hasn't marked
    /// them as read yet
    ///
    /// - Parameter completion: A callback that will call a `Result` with the number of unread
    /// secure conversation messages on success every time `unreadMessageCount` changes, or `Swift.Error` on failure.
    ///
    /// - returns:
    /// A unique callback ID or `nil` if callback was not registered due to error.
    /// This callback ID could be used to usubscribe from Secure Conversation unread messages count updates.
    public func subscribeSecureUnreadMessageCount(_ completion: @escaping (Result<Int?, Error>) -> Void) -> String? {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "subscribeSecureUnreadMessageCount)",
            methodParams: ["completion"]
        )
        let token = environment.createUuid().uuidString
        let task = Task {
            do {
                for try await count in environment.coreSdk.secureConversations.subscribeForUnreadMessageCount() {
                    completion(.success(count))
                }
            } catch is CancellationError {
                return
            } catch {
                completion(.failure(error))
            }
        }
        environment.subscriptionStore.store(task, for: token)
        return token
    }

    /// Remove subscription for 'subscribeToUnreadMessageCount' methods updates.
    /// 
    /// - Parameter subscriptionToken: Subscription token produced by `subscribeToUnreadMessageCount` method.
    public func unsubscribeSecureUnreadMessageCount(_ subscriptionToken: String) {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "unsubscribeSecureUnreadMessageCount(_:)",
            methodParams: ["subscriptionToken"]
        )
        environment.subscriptionStore.cancel(subscriptionToken)
    }

    /// Async equivalent of `getUnreadMessageCount(_:)`.
    public func getUnreadMessageCount() async throws -> Int {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "getUnreadMessageCount",
            methodParams: []
        )
        return try await environment.coreSdk.secureConversations.getUnreadMessageCount()
    }

    /// Async sequence equivalent of `subscribeSecureUnreadMessageCount(_:)`.
    public func subscribeSecureUnreadMessageCount() -> AsyncThrowingStream<Int?, Error> {
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "subscribeSecureUnreadMessageCount",
            methodParams: []
        )
        return environment.coreSdk.secureConversations.subscribeForUnreadMessageCount()
    }
}

extension SecureConversations {
    struct Environment {
        let coreSdk: CoreSdkClient
        var createUuid: () -> UUID = UUID.init
        let subscriptionStore = SubscriptionStore()
        @Dependency(\.widgets.openTelemetry) var openTelemetry: OpenTelemetry
    }

    final class SubscriptionStore {
        private let tasks: LockIsolated<[String: Task<Void, Never>]> = .init([:])

        deinit {
            tasks.value.values.forEach { $0.cancel() }
        }

        func store(_ task: Task<Void, Never>, for token: String) {
            tasks.withValue { tasks in
                tasks[token]?.cancel()
                tasks[token] = task
            }
        }

        func cancel(_ token: String) {
            tasks.withValue { tasks in
                tasks.removeValue(forKey: token)?.cancel()
            }
        }
    }
}

extension SecureConversations.Environment {
    static func create(with environment: Glia.Environment) -> Self {
        .init(coreSdk: environment.coreSdk)
    }
}
