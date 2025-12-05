import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension CallVisualizer.VideoCallViewModel {
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
        case .disconnected:
            let style = environment.theme.invertedNoConnectionSnackBarStyle
            delegate?(.showSnackBarView(
                dismissTiming: .manual(dismiss: { [weak self] callBack in
                    self?.hideNoConnectionSnackBar = callBack
                }),
                style: style
            ))
        @unknown default:
            return
        }
    }
}
