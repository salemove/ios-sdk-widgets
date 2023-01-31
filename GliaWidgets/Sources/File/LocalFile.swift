import UIKit

class LocalFile {
    lazy var fileExtension: String = { return url.pathExtension }()
    lazy var fileName: String = { return url.lastPathComponent }()
    lazy var fileSize: Int64? = {
        guard let attributes = try? environment.fileManager.attributesOfItemAtPath(url.path)  else { return nil }
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
        return ["jpg", "jpeg", "png", "gif"].contains(where: {
            $0.lowercased() == fileExtension.lowercased()
        })
    }()
    let url: URL

    private var thumbnail: UIImage?

    var environment: Environment

    init(with url: URL, environment: Environment) {
        self.url = url
        self.environment = environment
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
            environment.localFileThumbnailQueue.addOperation { [weak self] in
                guard let self = self else { return }
                guard let image = self.environment.uiImage.imageWithContentsOfFileAtPath(
                    self.url.standardizedFileURL.path
                ) else {
                    self.environment.gcd.mainQueue.async {
                        completion(nil)
                    }
                    return
                }
                let thumbnail = image.resized(to: size)
                self.thumbnail = thumbnail
                self.environment.gcd.mainQueue.async {
                    completion(thumbnail)
                }
            }
        }
    }
}

extension LocalFile: Equatable {
    static func == (lhs: LocalFile, rhs: LocalFile) -> Bool {
        return lhs.url == rhs.url
    }
}

extension LocalFile {
    struct AccessibilityProperties {
        var value: String?
    }

    var accessibilityProperties: AccessibilityProperties {
        return .init(value: fileInfoString)
    }
}
