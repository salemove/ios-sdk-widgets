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
                            title: L10n.Call.Buttons.Video.title,
                            accessibility: .init(label: L10n.Call.Accessibility.Buttons.Video.Active.label)
                        )
                    ),
                    muteButton: .mock(
                        inactive: .inactiveMock(
                            image: Asset.callMuteInactive.image,
                            title: L10n.Call.Buttons.Mute.Inactive.title,
                            accessibility: .init(label: L10n.Call.Accessibility.Buttons.Mute.Inactive.label)
                        )
                    ),
                    speakerButton: .mock(
                        inactive: .inactiveMock(
                            image: Asset.callSpeakerInactive.image,
                            title: L10n.Call.Buttons.Speaker.title,
                            accessibility: .init(label: L10n.Call.Accessibility.Buttons.Speaker.Inactive.label)
                        )
                    ),
                    minimizeButton: .mock(
                        inactive: .inactiveMock(
                            image: Asset.callMiminize.image,
                            title: L10n.Call.Buttons.Minimize.title,
                            accessibility: .init(label: L10n.Call.Accessibility.Buttons.Minimize.Inactive.label)
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
        let props: CallVisualizer.VideoCallViewController.Props = .init(videoCallViewProps: videoCallViewProps)

        let videoCallViewController: CallVisualizer.VideoCallViewController = .mock(props: props)
        videoCallViewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: videoCallViewController,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: videoCallViewController,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }
}
// swiftlint:enable type_name
