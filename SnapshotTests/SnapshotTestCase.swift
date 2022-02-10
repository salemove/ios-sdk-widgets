import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class SnapshotTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        SnapshotTestCase.checkSimulatorEnvironment()
    }
}

extension SnapshotTestCase {
    private struct TestDeviceConfig {
        let systemVersion: String
        let screenSize: CGSize
        let screenScale: CGFloat

        func matchesCurrentDevice() -> Bool {
            let device = UIDevice.current
            let screen = UIScreen.main

            return device.systemVersion == systemVersion
                && screen.bounds.size == screenSize
                && screen.scale == screenScale
        }
    }

    private static let testedDevices = [
        // iPhone 13, iOS 15.2
        TestDeviceConfig(
            systemVersion: "15.2",
            screenSize: CGSize(
                width: 390,
                height: 844
            ),
            screenScale: 3
        )
    ]

    private static func checkSimulatorEnvironment() {
        guard SnapshotTestCase.testedDevices.contains(where: { $0.matchesCurrentDevice() }) else {
            fatalError("Attempting to run tests on a device for which we have not collected test data")
        }

        guard UIApplication.shared.preferredContentSizeCategory == .large else {
            fatalError("Tests must be run on a device that has Dynamic Type disabled")
        }
    }

    func nameForDevice(baseName: String? = nil) -> String {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let version = UIDevice.current.systemVersion
        let deviceName = "\(Int(size.width))x\(Int(size.height))-\(version)-\(Int(scale))x"

        return [baseName, deviceName]
            .compactMap { $0 }
            .joined(separator: "-")
    }
}
