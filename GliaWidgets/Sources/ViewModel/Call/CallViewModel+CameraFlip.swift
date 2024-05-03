import Foundation

extension CallViewModel {
    func showCameraFlipIfNeeded() {
        let flipCameraCallback: Cmd?

        defer {
            self.action?(.setCameraFlip(flipCameraCallback))
        }

        do {
            let cameraDeviceManager = try environment.cameraDeviceManager()
            let devices = cameraDeviceManager.cameraDevices().filter { $0.facing == .front || $0.facing == .back }
            // Camera flip only makes sense when there are at least two camera devices.
            guard devices.count >= 2 else {
                flipCameraCallback = nil
                return
            }

            flipCameraCallback = Cmd { [environment] in
                // Get currently active camera device.
                let currentDevice = cameraDeviceManager.currentCameraDevice()
                // Find corresponding index for active camera
                let currentIndex = currentDevice.flatMap { devices.firstIndex(of: $0) }
                // and increase it by one.
                let nextIndex = currentIndex.flatMap { $0.advanced(by: 1) }

                if let nextIndex {
                    // If next index is valid use it for next device selection, otherwise use first device.
                    let nextDevice = devices.indices.contains(nextIndex) ? devices[nextIndex] : devices[0]
                    cameraDeviceManager.setCameraDevice(nextDevice)
                } else {
                    let warningMessage = """
                                         Unable to change camera device:
                                            - currentDevice: '\(String(describing: currentDevice?.name))',
                                            - currentIndex: '\(String(describing: currentIndex))',
                                            - nextIndex: '\(String(describing: nextIndex))'.
                                         """

                    environment.log.warning(warningMessage)
                }
            }
        } catch {
            flipCameraCallback = nil

            let warningMessage: String

            if let error = error as? CoreSdkClient.GliaCoreError {
                warningMessage = "Unable to access camera device manager: '\(error.reason)'."
            } else {
                warningMessage = "Unable to access camera device manager: '\(error)'."
            }

            environment.log.warning(warningMessage)
        }
    }
}
