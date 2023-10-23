import Foundation
import Combine

/// `FpsMonitor` is responsible for monitoring the current network 
/// connection type and adjusting the frame rate (FPS) accordingly.
///
/// This class listens for changes in the network connection 
/// type and updates the `currentFPS` based on the provided
/// `unlimitedFps` and `meteredFps` values.
final class FpsMonitor {
    var currentFPS: AnyPublisher<Int, Never> {
        return currentFPSSubject.eraseToAnyPublisher()
    }

    private var currentFPSSubject = CurrentValueSubject<Int, Never>(1)
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

        environment.networkMonitor.connectionTypePublisher
            .map { connectionType -> Int in
                switch connectionType {
                case .unlimited:
                    return self.unlimitedFps
                case .metered, .unknown:
                    return self.meteredFps
                }
            }
            .subscribe(currentFPSSubject)
            .store(in: &cancellables)
    }
}

extension FpsMonitor {
    struct Environment {
        let networkMonitor: NetworkConnectionMonitor
    }
}
