import Foundation
import Combine

extension AnyPublisher {
    static func mock<T>() -> AnyPublisher<T, Never> {
        return Empty().eraseToAnyPublisher()
    }

    static func mock<T>(_ value: T) -> AnyPublisher<T, Never> {
        return Just(value).eraseToAnyPublisher()
    }
}
