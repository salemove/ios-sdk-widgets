import Foundation

struct ProcessInfoHandling {
    var info: () -> [String: String]
}

extension ProcessInfoHandling {
    enum Key: String {
        /// `MAXIMUM_UPLOADS_PER_MESSAGE` is used in acceptance tests to decrease the time
        /// for uploading maximum number of files in a single message.
        case maximumUploads = "MAXIMUM_UPLOADS_PER_MESSAGE"
    }
}

extension ProcessInfoHandling {
    func value(for key: Key) -> String? {
        info()[key.rawValue]
    }
}
