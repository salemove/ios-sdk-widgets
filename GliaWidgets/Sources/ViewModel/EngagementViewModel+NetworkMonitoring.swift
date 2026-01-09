import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension EngagementViewModel {
    func subscribeOnNetworkReachabilityChanges() {
        let task = Task { [weak self] in
            guard let self else { return }

            if Task.isCancelled { return }

            let stream = self.environment.networkConnectionMonitor.networkStream(true)
            for await status in stream {
                if Task.isCancelled { return }
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
            engagementAction?(.showNoConnectionSnackBarView(
                dismissTiming: .manual(dismiss: { [weak self] callBack in
                    self?.hideNoConnectionSnackBar = callBack
                })
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
