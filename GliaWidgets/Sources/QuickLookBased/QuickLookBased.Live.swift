import Foundation
import UIKit
import QuickLook

extension QuickLookBased.ThumbnailGenerator {
    static func live(_ generator: QLThumbnailGenerator) -> Self {
        return .init(
            generateBestRepresentation: { request, completion in
                generator.generateBestRepresentation(for: request) { thumbnail, error in
                    completion(thumbnail.map(QuickLookBased.ThumbnailRepresentation.init(live:)), error)
                }
            }
        )
    }

    func createImageThumbnail(
        fileURL: URL,
        size: CGSize,
        scale: CGFloat,
        completion: @escaping (UIImage?) -> Void
    ) {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL.standardizedFileURL,
            size: newSize,
            scale: 1,
            representationTypes: .thumbnail
        )
        generateBestRepresentation(request) { thumbnail, error in
            if let image = thumbnail?.uiImage {
                completion(image)
            } else if let error {
                // TODO: need to handle error state
                print("Generating thumbnail failed with error `\(error)`")
            }
        }
    }
}

extension QuickLookBased.ThumbnailRepresentation {
    init(live: QLThumbnailRepresentation) {
        self.uiImage = live.uiImage
    }
}
