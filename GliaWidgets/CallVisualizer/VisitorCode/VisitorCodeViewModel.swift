import UIKit
import SalemoveSDK

extension CallVisualizer {
    class VisitorCodeViewModel {
        let presentation: CallVisualizer.Presentation
        var environment: Environment
        var delegate: (Delegate) -> Void
        var timer: FoundationBased.Timer?
        var theme: Theme
        var receivedVisitorCode: VisitorCode? {
            didSet {
                notifyPropsUpdated()
                scheduleVisitorCodeRefresh()
            }
        }

        init(
            presentation: CallVisualizer.Presentation,
            visitorCodeStyle: VisitorCodeStyle,
            environment: Environment,
            theme: Theme,
            delegate: @escaping (Delegate) -> Void
        ) {
            self.presentation = presentation
            self.environment = environment
            self.delegate = delegate
            self.theme = theme
        }

        func makeProps() -> VisitorCodeViewController.Props {
            let viewType: VisitorCodeView.Props.ViewType

            switch presentation {
            case .alert:
                viewType = .alert(closeButtonTap: Cmd { [weak self] in self?.delegate(.closeButtonTap) })
            case .embedded:
                viewType = .embedded
            }

            let codeViewProps = VisitorCodeView.Props(
                viewType: viewType,
                style: theme.visitorCodeStyle,
                visitorCode: receivedVisitorCode?.code ?? "",
                isPoweredByShown: theme.showsPoweredBy
            )
            return .init(visitorCodeViewProps: codeViewProps)
        }

        func notifyPropsUpdated() {
            delegate(.propsUpdated(makeProps()))
        }

        func requestVisitorCode() {
            _ = environment.requestVisitorCode { [weak self] result in
                switch result {
                case let .success(code):
                    self?.receivedVisitorCode = code
                case let .failure(error):
                    debugPrint(error.localizedDescription)
                }
            }
        }

        func scheduleVisitorCodeRefresh() {
            timer?.invalidate()
            guard let expDate = receivedVisitorCode?.expiresAt else { return }
            timer = environment.timerProviding.scheduledTimer(
                withTimeInterval: expDate.timeIntervalSinceNow,
                repeats: false
            ) { [weak self] _ in
                self?.requestVisitorCode()
            }
        }
    }
}
