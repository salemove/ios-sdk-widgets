import UniformTypeIdentifiers

protocol AttachmentOptions {
    var allowedFileContentTypes: [String] { get }
}

extension AttachmentOptions {
    var allowedAttachmentOptions: [AttachmentSourceItemKind] {
        var options: [AttachmentSourceItemKind] = []

        if isLibraryAttachmentAllowed {
            options.append(.photoLibrary)
        }

        if isPhotoVideoAttachmentAllowed {
            options.append(.takePhotoOrVideo)
        } else if isPhotoAttachmentAllowed {
            options.append(.takePhoto)
        } else if isVideoAttachmentAllowed {
            options.append(.takeVideo)
        }

        if isBrowseAttachmentAllowed {
            options.append(.browse)
        }

        return options
    }

    var allowedMediaTypes: [MediaPickerViewModel.MediaType] {
        if isPhotoVideoAttachmentAllowed {
            return [.image, .movie]
        } else if isPhotoAttachmentAllowed {
            return [.image]
        } else if isVideoAttachmentAllowed {
            return [.movie]
        }
        return []
    }

    private var allowedMediaContentTypes: [String] {
        return allowedFileContentTypes.filter { contentType in
            contentType.hasPrefix("image/") || contentType.hasPrefix("video/")
        }
    }

    private var isLibraryAttachmentAllowed: Bool {
        return !allowedMediaContentTypes.isEmpty
    }

    private var isPhotoAttachmentAllowed: Bool {
        return allowedMediaContentTypes.contains(where: { $0 == "image/jpeg" })
    }

    private var isVideoAttachmentAllowed: Bool {
        return allowedMediaContentTypes.contains(where: { $0 == "video/quicktime" })
    }

    private var isPhotoVideoAttachmentAllowed: Bool {
        return isPhotoAttachmentAllowed && isVideoAttachmentAllowed
    }

    private var isBrowseAttachmentAllowed: Bool {
        return !allowedFileContentTypes.isEmpty
    }
}

extension Array where Element == String {
    func mimeTypesToUTIs() -> [String] {
        return compactMap { mimeType in
            UTType(mimeType: mimeType)?.identifier
        }
    }
}
