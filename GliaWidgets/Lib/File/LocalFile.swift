import UIKit

class LocalFile {
    lazy var fileExtension: String = { return url.pathExtension }()
    lazy var fileName: String = { return url.lastPathComponent }()
    lazy var fileSize: Int64? = {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else { return nil }
        return attributes[.size] as? Int64
    }()
    lazy var fileSizeString: String? = {
        guard let fileSize = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }()
    lazy var fileInfoString: String? = {
        if !fileName.isEmpty, let fileSizeString = fileSizeString {
            return "\(fileName) • \(fileSizeString)"
        } else if !fileName.isEmpty {
            return fileName
        } else if let fileSizeString = fileSizeString {
            return fileSizeString
        } else {
            return nil
        }
    }()
    lazy var isImage: Bool = {
        return ["jpg", "jpeg", "png", "gif", "tif", "tiff", "bmp"].contains(fileExtension)
    }()

    let url: URL

    private var thumbnail: UIImage?

    init(with url: URL) {
        self.url = url
    }
}

extension LocalFile {
    func thumbnail(for size: CGSize, completion: @escaping (UIImage?) -> Void) {
        guard isImage else {
            completion(nil)
            return
        }

        if let thumbnail = thumbnail {
            completion(thumbnail)
            return
        } else {
            let scaleFactor = UIScreen.main.scale
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let targetSize = size.applying(scale)
            DispatchQueue.global(qos: .background).async {
                guard let image = UIImage(contentsOfFile: self.url.path) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                if image.size.width > targetSize.width, image.size.height > targetSize.height {
                    let image = self.resizeImage(image, size: targetSize)
                    self.thumbnail = image
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    self.thumbnail = image
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
    }

    private func resizeImage(_ image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension LocalFile: Equatable {
    static func == (lhs: LocalFile, rhs: LocalFile) -> Bool {
        return lhs.url == rhs.url
    }
}
