import Foundation

#if DEBUG
extension OperatorRequestHandlerService {
    static func mock() -> OperatorRequestHandlerService {
        .init(
            environment: .init(
                uiApplication: .mock,
                log: .mock
            ),
            viewFactory: .mock()
        )
    }
}
#endif
