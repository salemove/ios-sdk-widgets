import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension ChatViewModel {
    func subscribeOnNetworkReachabilityChanges() {
        let task = Task { [weak self] in
            guard let strongRef = self else { return }

            if Task.isCancelled { return }

            let stream = strongRef.environment.networkConnectionMonitor.networkStream(true)
            for await status in stream {
                if Task.isCancelled { return }
                await strongRef.handleNetworkStatus(status)
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
            let style = environment.viewFactory.theme.noConnectionSnackBarStyle
            action?(.showSnackBarView(
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
