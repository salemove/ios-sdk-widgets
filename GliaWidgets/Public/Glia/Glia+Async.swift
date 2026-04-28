import Foundation

public extension Glia {
    /// Setup SDK using specific engagement configuration without starting the engagement.
    ///
    /// Async equivalent of
    /// `configure(with:theme:uiConfig:assetsBuilder:features:completion:)`.
    func configure(
        with configuration: Configuration,
        theme: Theme = Theme(),
        uiConfig: RemoteConfiguration? = nil,
        assetsBuilder: RemoteConfiguration.AssetsBuilder = .standard,
        features: Features = .all
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try configure(
                    with: configuration,
                    theme: theme,
                    uiConfig: uiConfig,
                    assetsBuilder: assetsBuilder,
                    features: features,
                    completion: { result in
                        continuation.resume(with: result)
                    }
                )
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Clear visitor session.
    ///
    /// Async equivalent of `clearVisitorSession(_:)`.
    func clearVisitorSession() async throws {
        try await withCheckedThrowingContinuation { continuation in
            clearVisitorSession { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Fetch current visitor information.
    ///
    /// Async equivalent of `getVisitorInfo(completion:)`.
    func getVisitorInfo() async throws -> VisitorInfo {
        try await withCheckedThrowingContinuation { continuation in
            getVisitorInfo { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Update current visitor information.
    ///
    /// Async equivalent of `updateVisitorInfo(_:completion:)`.
    func updateVisitorInfo(_ info: VisitorInfoUpdate) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            updateVisitorInfo(info) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Ends active engagement if existing and closes Widgets SDK UI.
    ///
    /// Async equivalent of `endEngagement(_:)`.
    func endEngagement() async throws {
        try await withCheckedThrowingContinuation { continuation in
            endEngagement { result in
                continuation.resume(with: result)
            }
        }
    }

    /// List all queues of the configured site.
    ///
    /// Async equivalent of `getQueues(_:)`.
    func getQueues() async throws -> [Queue] {
        try await withCheckedThrowingContinuation { continuation in
            getQueues { result in
                continuation.resume(with: result)
            }
        }
    }
}
