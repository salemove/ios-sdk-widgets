import Foundation

public class ContextingAPIClient {
    public static let shared = ContextingAPIClient()

    public var baseURL: String = "http://localhost:4006"
    public var authToken: String = "eyJhbGciOiJFUzI1NiIsImtpZCI6ImZmYWZiY2Q1LWRmNjktNDRiMC1iMmUxLTQyYTViNTM0N2JmNiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiYTIwNDkzNWQtNmI3OC00YTBiLThmMjEtMzk4YWJkMTFiZDdjIiwiYXV0aF9zY2hlbWEiOm51bGwsImV4cCI6MTc2NTM4MDkyOCwiaWF0IjoxNzY1Mzc3MzI4LCJpc3MiOiJTYWxlTW92ZSBPcGVyYXRvciBBdXRoIiwicm9sZXMiOlt7Im9wZXJhdG9yX2lkIjoiNmEyMDVlYmEtYWYzZi00MGU3LTg3MzQtYmFmNWE4ZDZjOTg2IiwidHlwZSI6Im9wZXJhdG9yIn0seyJyb2xlIjoib3BlcmF0b3IiLCJzaXRlX2lkIjoiMjAwYTQ0ZDItZTk4ZS00NjljLThmY2EtMWZkZjhjMjVhNmZlIiwidHlwZSI6InNpdGVfb3BlcmF0b3IifV0sInN1YiI6Im9wZXJhdG9yOjZhMjA1ZWJhLWFmM2YtNDBlNy04NzM0LWJhZjVhOGQ2Yzk4NiJ9.p_mOjY0Vv6W-y-aIjsw0KUhIrlXL7VvE3py5ppqDQRAxe8g00anLqQPI6Qm9c944Zc85MZIPSSmvAKrVTm_C9g"

    private let httpClient: HTTPClient

    private init(httpClient: HTTPClient = HTTPClient.shared) {
        self.httpClient = httpClient
    }

    public func sendContextingRequest(
        prompt: String,
        completion: @escaping (Result<String, ContextingAPIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/mobile-engagement-contexting") else {
            completion(.failure(.invalidConfiguration))
            return
        }

        let requestBody = ContextingRequest(prompt: prompt)

        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(requestBody) else {
            completion(.failure(.invalidConfiguration))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        httpClient.post(request: request, jsonData: jsonData) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(ContextingResponse.self, from: data) {
                    completion(.success(response.response))
                } else {
                    completion(.failure(.serverError))
                }

            case .failure(let error):
                if let httpError = error as? HTTPClientError {
                    switch httpError {
                    case .httpError(let statusCode):
                        switch statusCode {
                        case 401:
                            completion(.failure(.unauthorized))
                        case 422:
                            completion(.failure(.validationError))
                        case 500:
                            completion(.failure(.serverError))
                        default:
                            completion(.failure(.serverError))
                        }
                    case .invalidResponse:
                        completion(.failure(.serverError))
                    }
                } else {
                    completion(.failure(.networkError))
                }
            }
        }
    }
}

private struct ContextingRequest: Codable {
    let prompt: String
}

private struct ContextingResponse: Codable {
    let response: String
}

public enum ContextingAPIError: Error, LocalizedError {
    case invalidConfiguration
    case unauthorized
    case validationError
    case serverError
    case networkError

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid API configuration (URL or encoding failed)"
        case .unauthorized:
            return "Missing or invalid JWT token (401)"
        case .validationError:
            return "Missing prompt field (422)"
        case .serverError:
            return "Bedrock API failure or model invocation issues (500)"
        case .networkError:
            return "Network connectivity error"
        }
    }
}
