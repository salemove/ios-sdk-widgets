import UIKit

extension AttachmentSourceListStyle {
    func apply(
        configuration: RemoteConfiguration.AttachmentSourceList?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        configuration?.separator?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { separatorColor = $0 }

        configuration?.background?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { backgroundColor = $0 }

        configuration?.items?.forEach { item in
            let sourceType = AttachmentSourceItemKind(rawValue: item.type.rawValue)
            items.first(where: { $0.kind == sourceType })?
                .apply(
                    configuration: item,
                    assetsBuilder: assetsBuilder
                )
        }
    }
}
