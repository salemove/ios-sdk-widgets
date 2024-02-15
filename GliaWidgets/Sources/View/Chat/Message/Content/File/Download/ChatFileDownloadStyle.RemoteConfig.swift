import UIKit

extension ChatFileDownloadStyle {
    func apply(
        configuration: RemoteConfiguration.FileMessage?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        filePreview.apply(
            configuration: configuration?.preview,
            assetsBuilder: assetsBuilder
        )
        download.apply(
            configuration: configuration?.download,
            assetsBuilder: assetsBuilder
        )
        downloading.apply(
            configuration: configuration?.downloading,
            assetsBuilder: assetsBuilder
        )
        open.apply(
            configuration: configuration?.downloaded,
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

        configuration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }
    }
}
