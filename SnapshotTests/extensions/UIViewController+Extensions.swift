import UIKit
import SnapshotTesting

extension UIViewController {
    func assertSnapshot(
        as mode: SnapshotMode,
        in orientation: SnapshotOrientation = .portrait,
        bounds: CGRect = UIScreen.main.bounds,
        named name: String? = nil,
        record recording: Bool = false,
        file: StaticString = #file,
        functionName: String = #function,
        line: UInt = #line
    ) {
        self.view.bounds = bounds
        let snapshotting: Snapshotting<UIViewController, UIImage>
        switch mode {
        case .accessibilityImage:
            snapshotting = .accessibilityImage(precision: SnapshotTestCase.possiblePrecision)
        case .image:
            snapshotting = orientation == .portrait ? .image : .imageLandscape
        case .extra3LargeFont:
            snapshotting = orientation == .portrait ? .extra3LargeFontStrategy : .extra3LargeFontStrategyLandscape
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
        }
    }

    enum SnapshotOrientation {
        case portrait
        case landscape
    }

    enum SnapshotMode {
        case accessibilityImage
        case image
        case extra3LargeFont
    }
}
