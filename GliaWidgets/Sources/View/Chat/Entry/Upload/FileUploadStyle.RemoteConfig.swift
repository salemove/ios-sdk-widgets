import UIKit

extension FileUploadStyle {
    mutating func apply(
        // TODO: provide configuration for disabled state MOB-3762.
        configuration: RemoteConfiguration.FileUploadBar?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        enabled.filePreview.apply(
            configuration: configuration?.filePreview,
            assetsBuilder: assetsBuilder
        )
        enabled.uploading.apply(
            configuration: configuration?.uploading,
            assetsBuilder: assetsBuilder
        )
        enabled.uploaded.apply(
            configuration: configuration?.uploaded,
            assetsBuilder: assetsBuilder
        )
        enabled.error.apply(
            configuration: configuration?.error,
            assetsBuilder: assetsBuilder
        )

        configuration?.progress?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { enabled.progressColor = $0 }

        configuration?.errorProgress?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { enabled.errorProgressColor = $0 }

        configuration?.progressBackground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { enabled.progressBackgroundColor = $0 }

        configuration?.removeButton?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { enabled.removeButtonColor = $0 }
    }
}
