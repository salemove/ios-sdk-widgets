import Foundation
import GliaCoreSDK

extension CallVisualizer.VideoCallViewModel {
    func subscribeOnCallQualityChanges() {
        let stream = environment.callQualityMonitor.mediaQualityStream()
        let task = Task { [weak self] in
            if Task.isCancelled { return }

            for await mediaQuality in stream {
                if Task.isCancelled { return }
                guard let self else { return }
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
