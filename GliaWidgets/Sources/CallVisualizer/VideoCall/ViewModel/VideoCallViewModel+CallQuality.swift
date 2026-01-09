import Foundation
import GliaCoreSDK

extension CallVisualizer.VideoCallViewModel {
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
            delegate?(.setPoorCallQualityIndicatorHidden(false))
        case .good:
            delegate?(.setPoorCallQualityIndicatorHidden(true))
        @unknown default:
            return
        }
    }
}
