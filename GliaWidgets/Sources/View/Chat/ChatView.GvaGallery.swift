import UIKit

extension ChatView {
    func gvaGalleryListViewContent(
        _ message: ChatMessage,
        gallery: GvaGallery,
        showsImage: Bool,
        imageUrl: String?
    ) -> ChatItemCell.Content {
        let listViewEnvironment = GvaGalleryListView.Environment(
            data: environment.data,
            uuid: environment.uuid,
            gcd: environment.gcd,
            imageViewCache: environment.imageViewCache,
            uiScreen: environment.uiScreen
        )
        let view = GvaGalleryListView(environment: listViewEnvironment)
        let items = makeProps(for: gallery)
        let height = calculateHeight(for: view, props: items)
        view.props = .init(
            items: items,
            style: style.gliaVirtualAssistant.galleryList
        )
        view.showsOperatorImage = showsImage
        return .gvaGallery(view, height)
    }

    private func calculateHeight(
        for galleryListView: GvaGalleryListView,
        props: [GvaGalleryCardView.Props]
    ) -> CGFloat {
        var height = props.reduce(0) { height, item in
            let view = GvaGalleryCardView()
            view.props = item
            let size = view.sizeThatFits(.init(width: .zero, height: CGFloat.greatestFiniteMagnitude))
            return max(height, size.height)
        }
        height += galleryListView.sectionInsets.top
        height += galleryListView.sectionInsets.bottom
        return height
    }

    private func makeProps(for gallery: GvaGallery) -> [GvaGalleryCardView.Props] {
        return gallery.galleryCards.map { card in
            let options = card.options?.map { option in
                GvaGalleryCardView.Props.Option(
                    title: option.text,
                    action: .init { [weak self] in self?.gvaButtonTapped?(option) }
                )
            } ?? []
            var image: GvaGalleryCardView.Props.Image?
            if let urlString = card.imageUrl, let url = URL(string: urlString) {
                image = GvaGalleryCardView.Props.Image(
                    url: url,
                    environment: .init(
                        data: environment.data,
                        uuid: environment.uuid,
                        gcd: environment.gcd,
                        imageViewCache: environment.imageViewCache
                    )
                )
            }
            return GvaGalleryCardView.Props(
                title: card.title,
                subtitle: card.subtitle,
                image: image,
                options: options,
                style: style.gliaVirtualAssistant.galleryList.cardStyle
            )
        }
    }
}
