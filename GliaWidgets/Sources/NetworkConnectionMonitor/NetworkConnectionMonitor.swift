import Network
import Combine

class NetworkConnectionMonitor: ObservableObject {
    @Published private(set) var connectionType: ConnectionType = .unknown

    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            guard path.status == .satisfied else { 
                // No conection to the internet
                self.connectionType = .unknown
                return
            }

            if path.usesInterfaceType(.wifi) {
                self.connectionType = .unlimited
            } else if path.usesInterfaceType(.cellular) {
                self.connectionType = .metered
            } else {
                self.connectionType = .unknown
            }
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
