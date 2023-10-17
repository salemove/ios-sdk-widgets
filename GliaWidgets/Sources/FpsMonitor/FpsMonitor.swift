import Foundation
import Combine

class FpsMonitor {
    @Published private(set) var currentFPS: Int = 1

    private let unlimitedFps: Int
    private let meteredFps: Int
    private var cancellables: Set<AnyCancellable> = []

    init(
        environment: Environment,
        unlimitedFps: Int,
        meteredFps: Int
    ) {
        self.unlimitedFps = unlimitedFps
        self.meteredFps = meteredFps

        environment.networkMonitor.$connectionType
            .map { connectionType -> Int in
                switch connectionType {
                case .unlimited:
                    return self.unlimitedFps
                case .metered, .unknown:
                    return self.meteredFps
                }
            }
            .assign(to: \.currentFPS, on: self)
            .store(in: &cancellables)
    }
}

extension FpsMonitor {
    struct Environment {
        let networkMonitor: NetworkConnectionMonitor
    }
}
