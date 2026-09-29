import UIKit

enum EngagementLayoutMode: Equatable {
    case fullScreen
    case sidePanel
}

extension EngagementLayoutMode {
    static let sidePanelMinimumSceneWidth: CGFloat = 768

    static func resolve(idiom: UIUserInterfaceIdiom, sceneWidth: CGFloat) -> EngagementLayoutMode {
        guard idiom == .pad else { return .fullScreen }
        return sceneWidth >= sidePanelMinimumSceneWidth ? .sidePanel : .fullScreen
    }

    static func resolve(for windowScene: UIWindowScene?) -> EngagementLayoutMode {
        guard let windowScene else { return .fullScreen }
        return resolve(
            idiom: windowScene.traitCollection.userInterfaceIdiom,
            sceneWidth: windowScene.coordinateSpace.bounds.width
        )
    }
}
