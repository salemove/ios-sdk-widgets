import Foundation

extension RemoteConfiguration {
    struct CallVisualizer: Codable {
        let visitorCode: VisitorCode?
    }

    struct VisitorCode: Codable {
        let title: Text?
        let actionButton: Button?
        let numberSlotText: Text?
        let numberSlotBackground: Layer?
        let background: Layer?
        let loadingProgressColor: Color?
        let closeButtonColor: Color?
    }
}
