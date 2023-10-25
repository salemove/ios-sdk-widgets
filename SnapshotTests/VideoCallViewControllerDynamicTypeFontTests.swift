@testable import GliaWidgets
import SnapshotTesting
import XCTest

// swiftlint:disable type_name
final class VideoCallViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func testVideoCallViewController_extra3Large() {
        let videoCallViewProps: CallVisualizer.VideoCallView.Props = .mock(
            buttonBarProps: .mock(
                style: .mock(
                    chatButton: .mock(),
                    videButton: .mock(
                        inactive: .activeMock(
                            image: Asset.callVideoActive.image,
                            title: Localization.Engagement.Video.title,
                            accessibility: .init(label: Localization.General.selected)
                        )
                    ),
                    muteButton: .mock(
                        inactive: .inactiveMock(
                            image: Asset.callMuteInactive.image,
                            title: Localization.Call.Mute.button,
                            accessibility: .init(label: "")
                        )
                    ),
                    speakerButton: .mock(
                        inactive: .inactiveMock(
                            image: Asset.callSpeakerInactive.image,
                            title: Localization.Call.Speaker.button,
                            accessibility: .init(label: "")
                        )
                    ),
                    minimizeButton: .mock(
                        inactive: .inactiveMock(
                            image: Asset.callMiminize.image,
                            title: Localization.Engagement.MinimizeVideo.button,
                            accessibility: .init(label: "")
                        )
                    ),
                    badge: .mock()
                )
            ),
            headerProps: .mock(
                title: "Video",
                effect: .blur,
                backButton: .init(style: .mock(image: Asset.back.image))
            )
        )
        let props: CallVisualizer.VideoCallViewController.Props = .init(
            videoCallViewProps: videoCallViewProps,
            viewDidLoad: .nop
        )

        let viewController: CallVisualizer.VideoCallViewController = .mock(props: props)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
// swiftlint:enable type_name
