import UIKit
import SnapshotTesting

extension UIView {
    func assertSnapshot(
        as mode: SnapshotMode,
        in orientation: SnapshotOrientation = .portrait,
        named name: String? = nil,
        record recording: Bool = false,
        file: StaticString = #file,
        functionName: String = #function,
        line: UInt = #line
    ) {
        let snapshotting: Snapshotting<UIView, UIImage>
        switch (mode, orientation) {
        case (.accessibilityImage, _):
            snapshotting = .accessibilityImage(
                showActivationPoints: .never,
                precision: SnapshotTestCase.possiblePrecision
            )
        case (.image, .portrait):
            snapshotting = .image
        case (.image, .landscape):
            snapshotting = .imageLandscape
        case (.image, .padPanel):
            snapshotting = .imagePadPanel
        case (.extra3LargeFont, .portrait):
            snapshotting = .extra3LargeFontStrategy
        case (.extra3LargeFont, .landscape):
            snapshotting = .extra3LargeFontStrategyLandscape
        case (.extra3LargeFont, .padPanel):
            snapshotting = .extra3LargeFontStrategyPadPanel
        }
        let snapshotName = snapshotName(name, orientation: orientation)
        SnapshotTesting.assertSnapshot(
            matching: self,
            as: snapshotting,
            named: snapshotName,
            record: recording,
            file: file,
            testName: functionName,
            line: line
        )
    }

    func snapshotName(
        _ baseName: String? = nil,
        orientation: SnapshotOrientation
    ) -> String {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let version = UIDevice.current.systemVersion
        let deviceName = "\(Int(size.width))x\(Int(size.height))-\(version)-\(Int(scale))x"

        switch orientation {
        case .portrait:
            return [baseName, deviceName]
                .compactMap { $0 }
                .joined(separator: "-")
        case .landscape:
            return [baseName, deviceName, "landscape"]
                .compactMap { $0 }
                .joined(separator: "-")
        case .padPanel:
            // `deviceName` still comes from the simulator screen, so the suffix is
            // what keeps panel references apart from the portrait set.
            return [baseName, deviceName, "padPanel"]
                .compactMap { $0 }
                .joined(separator: "-")
        }
    }

    enum SnapshotOrientation {
        case portrait
        case landscape
        /// The 400pt-wide iPad side panel at full iPad height.
        case padPanel
    }

    enum SnapshotMode {
        case accessibilityImage
        case image
        case extra3LargeFont
    }
}
