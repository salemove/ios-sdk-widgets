import Foundation
import GliaCoreSDK

extension CallViewModel {
    func subscribeOnCallQualityChanges() {
        let task = Task { [weak self] in
            guard let self else { return }

            if Task.isCancelled { return }

            let stream = self.environment.callQualityMonitor.mediaQualityStream()
            for await mediaQuality in stream {
                if Task.isCancelled { return }
                await self.handleMediaQuality(mediaQuality)
            }
        }
        disposeBag.add(TaskDisposable(task))
    }

    @MainActor
    private func handleMediaQuality(_ mediaQuality: CoreSdkClient.MediaQuality) {
        switch mediaQuality {
        case .poor:
            action?(.setPoorCallQualityIndicatorHidden(false))
        case .good:
            action?(.setPoorCallQualityIndicatorHidden(true))
        @unknown default:
            return
        }
    }
}
