import Combine
import Network

final class NetworkConnectionMonitor {

    var connectionTypePublisher: AnyPublisher<ConnectionType, Never> {
        return connectionTypeSubject.eraseToAnyPublisher()
    }

    private var connectionTypeSubject = CurrentValueSubject<ConnectionType, Never>(.unknown)
    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            var connectionType: ConnectionType = .unknown

            guard path.status == .satisfied else {
                self.connectionTypeSubject.send(connectionType)
                return
            }

            if path.usesInterfaceType(.wifi) {
                connectionType = .unlimited
            } else if path.usesInterfaceType(.cellular) {
                connectionType = .metered
            }

            self.connectionTypeSubject.send(connectionType)
        }

        monitor?.start(queue: queue)
    }
}

extension NetworkConnectionMonitor {
    enum ConnectionType {
        case unlimited
        case metered
        case unknown
    }
}
