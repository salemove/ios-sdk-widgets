import Foundation

public class HTTPClient {
    public static let shared = HTTPClient()

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    public func post(
        request: URLRequest,
        jsonData: Data,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var mutableRequest = request
        mutableRequest.httpMethod = "POST"
        mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableRequest.httpBody = jsonData

        let task = session.dataTask(with: mutableRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(HTTPClientError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(HTTPClientError.httpError(statusCode: httpResponse.statusCode)))
                return
            }

            completion(.success(data ?? Data()))
        }

        task.resume()
    }
}

public enum HTTPClientError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid HTTP response received"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        }
    }
}