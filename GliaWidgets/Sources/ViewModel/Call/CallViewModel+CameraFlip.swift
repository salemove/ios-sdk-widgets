import Foundation

extension CallViewModel {
    /// Centralized method for getting flip camera related logic,
    /// along with UI properties, such as accessibility and button
    /// tap callback, which affects the button's accessibility label.
    /// This method is static, because it is reused by CallVisualizer.
    static func setFlipCameraButtonVisible(
        _ visible: Bool,
        getCameraDeviceManager: @escaping CoreSdkClient.GetCameraDeviceManageable,
        log: CoreSdkClient.Logger,
        flipCameraButtonStyle: FlipCameraButtonStyle,
        callback: @escaping (VideoStreamView.FlipCameraAccLabelWithTap?) -> Void
    ) {
        let flipCameraAccLabelWithCallback: VideoStreamView.FlipCameraAccLabelWithTap?

        defer {
            callback(flipCameraAccLabelWithCallback)
        }

        do {
            let cameraDeviceManager = try getCameraDeviceManager()
            let devices = cameraDeviceManager.cameraDevices().filter { $0.facing == .front || $0.facing == .back }
            // Camera flip only makes sense when there are at least two camera devices.
            guard devices.count >= 2 else {
                flipCameraAccLabelWithCallback = nil
                return
            }

            // Get currently active camera device and its related accessibility properties.
            let currentDevice = cameraDeviceManager.currentCameraDevice()
            let accessibility = flipCameraButtonStyle.accessibility

            // Get accessibility label for currently used device, in case if there's no
            // selected device, provide empty string for it.
            let propsAccessibility = (currentDevice?.facing).map(accessibility.flipCameraButtonPropsAccessibility(for:)) ?? .nop

            flipCameraAccLabelWithCallback = !visible ? nil : (propsAccessibility, Cmd {
                // Actualize current device again during callback execution
                // to avoid stale data.
                let currentDevice = cameraDeviceManager.currentCameraDevice()
                // Find corresponding index for active camera
                let currentIndex = currentDevice.flatMap { devices.firstIndex(of: $0) }
                // and increase it by one.
                let nextIndex = currentIndex.flatMap { $0.advanced(by: 1) }

                if let nextIndex {
                    // If next index is valid use it for next device selection, otherwise use first device.
                    let nextDevice = devices.indices.contains(nextIndex) ? devices[nextIndex] : devices[0]
                    cameraDeviceManager.setCameraDevice(nextDevice)
                    // We need to call `setCameraFlipVisible` to let
                    // accessibility label be propagated to button via
                    // props.
                    Self.setFlipCameraButtonVisible(
                        visible,
                        getCameraDeviceManager: getCameraDeviceManager,
                        log: log,
                        flipCameraButtonStyle: flipCameraButtonStyle,
                        callback: callback
                    )
                } else {
                    let warningMessage = """
                                         Unable to change camera device:
                                            - currentDevice: '\(String(describing: currentDevice?.name))',
                                            - currentIndex: '\(String(describing: currentIndex))',
                                            - nextIndex: '\(String(describing: nextIndex))'.
                                         """

                    log.warning(warningMessage)
                }
            })
        } catch {
            flipCameraAccLabelWithCallback = nil

            let warningMessage: String

            if let error = error as? CoreSdkClient.GliaCoreError {
                warningMessage = "Unable to access camera device manager: '\(error.reason)'."
            } else {
                warningMessage = "Unable to access camera device manager: '\(error)'."
            }

            log.warning(warningMessage)
        }
    }
}
