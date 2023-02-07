import Foundation

extension RemoteConfiguration {
    struct CallVisualizer: Codable {
        let visitorCode: VisitorCode?
        let screenSharing: ScreenSharing?
    }

    struct VisitorCode: Codable {
        let title: Text?
        let actionButton: Button?
        let numberSlot: NumberSlot?
        let background: Layer?
        let loadingProgressColor: Color?
    }

    struct ScreenSharing: Codable {
        let header: Header?
        let message: Text?
        let endButton: Button?
        let background: Layer?
    }

    struct NumberSlot: Codable {
        let background: Layer?
        let font: Font?
        let fontColor: Color?
    }
}
