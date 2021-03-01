import UIKit
import AVFoundation

final class MediaPickerController: NSObject {
    private let viewModel: MediaPickerViewModel
    private var imagePicker: UIImagePickerController?

    private var viewController: UIViewController {
        if let imagePicker = imagePicker {
            return imagePicker
        }

        let source = UIImagePickerController.SourceType(with: viewModel.source)
        let media = mediaTypes(viewModel.types, for: source)
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.mediaTypes = media
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        self.imagePicker = imagePicker

        return imagePicker
    }

    init(viewModel: MediaPickerViewModel) {
        self.viewModel = viewModel
    }

    func viewController(_ completion: @escaping (UIViewController) -> Void) {
        switch viewModel.source {
        case .camera:
            checkCameraPermission(completion)
        case .library:
            completion(viewController)
        }
    }

    private func mediaTypes(_ mediaTypes: [MediaPickerViewModel.MediaType],
                            for sourceType: UIImagePickerController.SourceType) -> [String] {
        let types: [String] = mediaTypes.map({
            switch $0 {
            case .image:
                return "public.image"
            case .movie:
                return "public.movie"
            }
        })

        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType) ?? []

        return types.filter({ availableMediaTypes.contains($0) })
    }

    private func checkCameraPermission(_ completion: @escaping (UIViewController) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.checkCameraPermission(completion)
                    }
                }
            }
            return
        case .restricted, .denied:
            viewModel.event(.noCameraPermission)
            return
        default:
            break
        }

        completion(viewController)
    }
}

extension MediaPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let url = info[.imageURL] as? URL {
            viewModel.event(.pickedImage(url))
        } else if let url = info[.mediaURL] as? URL {
            viewModel.event(.pickedMovie(url))
        }

        imagePicker = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        viewModel.event(.cancelled)
        imagePicker = nil
    }
}

private extension UIImagePickerController.SourceType {
    init(with source: MediaPickerViewModel.MediaSource) {
        switch source {
        case .camera:
            self = .camera
        case .library:
            self = .photoLibrary
        }
    }
}
