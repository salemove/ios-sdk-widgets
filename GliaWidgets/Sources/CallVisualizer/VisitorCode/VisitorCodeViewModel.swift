import UIKit

extension CallVisualizer {
    class VisitorCodeViewModel {
        let presentation: CallVisualizer.Presentation
        var environment: Environment
        var delegate: (Delegate) -> Void
        var timer: FoundationBased.Timer?
        var theme: Theme
        var visitorCodeExpiresAt: Date?
        var viewState: VisitorCodeView.Props.ViewState = .loading {
            didSet {
                notifyPropsUpdated()
                scheduleVisitorCodeRefresh()
            }
        }

        init(
            presentation: CallVisualizer.Presentation,
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
                viewState: viewState,
                style: theme.visitorCode,
                isPoweredByShown: theme.showsPoweredBy
            )
            return .init(visitorCodeViewProps: codeViewProps)
        }

        func notifyPropsUpdated() {
            delegate(.propsUpdated(makeProps()))
        }

        @MainActor
        func requestVisitorCode() async {
            do {
                let visitorCode = try await environment.requestVisitorCode()
                visitorCodeExpiresAt = visitorCode.expiresAt
                viewState = .success(visitorCode: visitorCode.code)
            } catch {
                viewState = .error(refreshTap: AsyncCmd { [weak self] in
                    self?.viewState = .loading
                    await self?.requestVisitorCode()
                })
                debugPrint("Error getting vistior code:", error.localizedDescription)
            }
        }

        func scheduleVisitorCodeRefresh() {
            timer?.invalidate()
            switch viewState {
            case .error, .loading:
                break
            case .success:
                guard let expirationDate = visitorCodeExpiresAt else { return }
                timer = environment.timerProviding.scheduledTimer(
                    withTimeInterval: expirationDate.timeIntervalSinceNow,
                    repeats: false
                ) { [weak self] _ in
                    Task {
                        await self?.requestVisitorCode()
                    }
                }
            }
        }
    }
}
