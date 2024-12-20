import UIKit
import GliaWidgets

extension ViewController {
    @IBAction private func remoteConfigTapped() {
        showRemoteConfigAlert { [weak self] fileName in
            guard fileName != nil else {
                self?.alert(message: "Could not find any json file")
                return
            }
            self?.showEngagementKindActionSheet { kind in
                self?.prepareGlia {
                    self?.catchingError {
                        try self?.startEngagement(kind)
                    }
                }
            }
        }
    }

    private func startEngagement(_ kind: EngagementKind) throws {
        switch kind {
        case .chat:
            try engagementLauncher?.startChat()
        case .audioCall:
            try engagementLauncher?.startAudioCall()
        case .videoCall:
            try engagementLauncher?.startVideoCall()
        case .messaging:
            try engagementLauncher?.startSecureMessaging()
        case .none:
            return
        @unknown default:
            return
        }
    }

    /// Shows alert with engagement kinds.
    /// - Parameter completion: Completion handler to be called on engagement kind selection.
    func showEngagementKindActionSheet(completion: @escaping (EngagementKind) -> Void) {
        let data: [(EngagementKind, String)] = [
            (.chat, "Chat"),
            (.audioCall, "Audio"),
            (.videoCall, "Video"),
            (.messaging(), "Messaging")
        ]
        let alert = UIAlertController(
            title: "Choose engagement type",
            message: nil,
            preferredStyle: .actionSheet
        )
        let action: ((kind: EngagementKind, title: String)) -> UIAlertAction = { data  in
            UIAlertAction(title: data.title, style: .default) { [weak alert] _ in
                completion(data.kind)
                alert?.dismiss(animated: true)
            }
        }
        data.map(action).forEach(alert.addAction)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func jsonNames() -> [String] {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: "UnifiedUI")
        return paths
            .compactMap(URL.init(string:))
            .compactMap {
                $0.lastPathComponent
                    .components(separatedBy: ".")
                    .first
            }.sorted()
    }

    func showRemoteConfigAlert(_ completion: @escaping (String?) -> Void) {
        let names = jsonNames()
        guard !names.isEmpty else {
            completion(nil)
            return
        }

        let alert = UIAlertController(
            title: "Remote configuration",
            message: "Selected config will be applied",
            preferredStyle: .actionSheet
        )
        let action: (String) -> UIAlertAction = { fileName in
            UIAlertAction(title: fileName, style: .default) { [weak alert] _ in
                completion(fileName)
                alert?.dismiss(animated: true)
            }
        }
        names.map(action).forEach(alert.addAction)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func retrieveRemoteConfiguration(_ fileName: String?) -> RemoteConfiguration? {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "UnifiedUI"),
            let jsonData = try? Data(contentsOf: url),
            let config = try? JSONDecoder().decode(RemoteConfiguration.self, from: .init(jsonData))
        else {
            print("Could not decode RemoteConfiguration.")
            return nil
        }
        return config
    }
}
