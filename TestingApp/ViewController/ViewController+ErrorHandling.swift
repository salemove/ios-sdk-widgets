import UIKit
import GliaWidgets
import GliaCoreSDK

extension ViewController {
    /// Report any thrown error via UIAlertController.
    /// - Parameter throwing: closure wrapping throwing code.
    func catchingError(_ throwing: () throws -> Void) {
        do {
            try throwing()
        } catch let error as GliaCoreError {
            self.alert(message: error.reason)
        } catch let error as ConfigurationError {
            self.alert(message: "Configuration error: '\(error)'.")
        } catch let error as GliaError {
            self.alert(message: "The operation couldn't be completed. '\(error)'.")
        } catch {
            self.alert(message: error.localizedDescription)
        }
    }

    func showErrorAlert(using error: Error) {
        if let gliaError = error as? GliaError {
            switch gliaError {
            case GliaError.engagementExists:
                alert(message: "Failed to start\nEngagement is ongoing, please use 'Resume' button")
            case GliaError.engagementNotExist:
                alert(message: "Failed to start\nNo ongoing engagement. Please start a new one with 'Start chat' button")
            case GliaError.callVisualizerEngagementExists:
                alert(message: "Failed to start\nCall Visualizer engagement is ongoing")
            case GliaError.configuringDuringEngagementIsNotAllowed:
                alert(message: "The operation couldn't be completed. '\(gliaError)'.")
            case GliaError.invalidSiteApiKeyCredentials:
                alert(message: "Failed to configure the SDK, invalid credentials")
            case GliaError.invalidLocale:
                alert(message: "Failed to configure the SDK, invalid locale override specified")
            default:
                alert(message: "Failed to start\nCheck Glia parameters in Settings")
            }
        } else {
            alert(message: "Failed to execute with error: \(error)\nCheck Glia parameters in Settings")
        }
    }

    func alert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        })))
        present(alert, animated: true, completion: nil)
    }
}
