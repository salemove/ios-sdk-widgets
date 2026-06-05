import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension CallVisualizer.VideoCallViewModel {
    func subscribeOnNetworkReachabilityChanges() {
        let stream = environment.networkConnectionMonitor.networkStream(true)
        let task = Task { [weak self] in
            if Task.isCancelled { return }

            for await status in stream {
                if Task.isCancelled { return }
                guard let self else { return }
                await self.handleNetworkStatus(status)
            }
        }
        disposeBag.add(TaskDisposable(task))
    }

    @MainActor
    private func handleNetworkStatus(_ status: CoreSdkClient.NetworkStatus) {
        switch status {
        case .connected:
            hideNoConnectionSnackBar?()
            hideNoConnectionSnackBar = nil
            logSnackBarEvent(.snackBarHidden)
        case .disconnected:
            let style = environment.theme.invertedNoConnectionSnackBarStyle
            delegate?(.showSnackBarView(
                dismissTiming: .manual(dismiss: { [weak self] callBack in
                    self?.hideNoConnectionSnackBar = callBack
                }),
                style: style
            ))
            logSnackBarEvent(.snackBarShown)
        @unknown default:
            return
        }
    }

    private func logSnackBarEvent(_ event: OtelLogEvents) {
        let attributesBuilder: OtelAttributesBuilder = {
            $0[.isAutoClosable] = .bool(false)
            $0[.type] = .string(OtelSnackBarTypes.connection.rawValue)
        }
        environment.openTelemetry.logger.i(
            event,
            attributesBuilder: attributesBuilder
        )
    }
}
