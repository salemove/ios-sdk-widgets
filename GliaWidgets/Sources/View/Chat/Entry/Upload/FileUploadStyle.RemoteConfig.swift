import UIKit

extension FileUploadStyle {
    func apply(
        configuration: RemoteConfiguration.FileUploadBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        filePreview.apply(
            configuration: configuration?.filePreview,
            assetsBuilder: assetsBuilder
        )
        uploading.apply(
            configuration: configuration?.uploading,
            assetsBuilder: assetsBuilder
        )
        uploaded.apply(
            configuration: configuration?.uploaded,
            assetsBuilder: assetsBuilder
        )
        error.apply(
            configuration: configuration?.error,
            assetsBuilder: assetsBuilder
        )

        configuration?.progress?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { progressColor = $0 }

        configuration?.errorProgress?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { errorProgressColor = $0 }

        configuration?.progressBackground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { progressBackgroundColor = $0 }

        configuration?.removeButton?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { removeButtonColor = $0 }
    }
}
