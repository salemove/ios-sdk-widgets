import Foundation

extension RemoteConfiguration {
    struct CallVisualizer: Codable {
        let visitorCode: VisitorCode?
        let screenSharing: ScreenSharing?
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

    struct ScreenSharing: Codable {
        let header: Header?
        let message: Text?
        let endButton: Button?
        let background: Layer?
    }
}
