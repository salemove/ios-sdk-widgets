import Foundation

protocol DataStorage {
    func store(_ data: Data, for key: String)
    func store(from url: URL, for key: String)
    func url(for key: String) -> URL
    func data(for key: String) -> Data?
    func hasData(for key: String) -> Bool
    func removeData(for key: String)
}

extension DataStorage {
    func storeInBackground(_ data: Data, for key: String) async {
        await withCheckedContinuation { continuation in
            storageQueue.async {
                self.store(data, for: key)
                continuation.resume()
            }
        }
    }

    func storeInBackground(from url: URL, for key: String) async {
        await withCheckedContinuation { continuation in
            storageQueue.async {
                self.store(from: url, for: key)
                continuation.resume()
            }
        }
    }
}

// Serialize attachment writes while keeping blocking file I/O off UI and Swift task executors.
private let storageQueue = DispatchQueue(label: "com.glia.widgets.attachment-storage", qos: .utility)
