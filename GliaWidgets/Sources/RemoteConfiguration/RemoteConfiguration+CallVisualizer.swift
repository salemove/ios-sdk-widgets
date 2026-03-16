import Foundation

extension RemoteConfiguration {
    final class CallVisualizer: Codable {
        let visitorCode: VisitorCode?
    }

    final class VisitorCode: Codable {
        let title: Text?
        let actionButton: Button?
        let numberSlotText: Text?
        let numberSlotBackground: Layer?
        let background: Layer?
        let loadingProgressColor: Color?
        let closeButtonColor: Color?
    }
}
