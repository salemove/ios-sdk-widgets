final class AlertViewModel {
    struct Input {
        var dismiss: (() -> Void)?
    }

    struct Output {
        let properties: AlertProperties
    }

    enum DelegateEvent {
        case dismiss
    }

    var delegate: ((DelegateEvent) -> Void)?

    private let properties: AlertProperties

    init(properties: AlertProperties) {
        self.properties = properties
    }

    func transform(_ input: inout Input) -> Output {
        input.dismiss = { [weak self] in
            self?.delegate?(.dismiss)
        }

        return Output(
            properties: properties
        )
    }
}
