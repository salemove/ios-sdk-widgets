import UIKit

private extension CGFloat {
    static let cardWidth: CGFloat = 234
    static let operatorImageSide: CGFloat = 28
}

final class GvaGalleryListView: BaseView {
    var props: Props = .nop {
        didSet {
            renderProps()
        }
    }
    var showsOperatorImage: Bool = false {
        didSet {
            operatorImageView.isHidden = !showsOperatorImage
        }
    }

    let sectionInsets = UIEdgeInsets(top: 8, left: 44, bottom: 8, right: 16)
    private let operatorImageInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)
    private let environment: Environment

    private lazy var operatorImageView = UserImageView(
        with: props.style.operatorImage,
        environment: .create(with: environment)
    )
    lazy var collectionView = SelfSizingCollectionView(
        frame: .zero,
        collectionViewLayout: createCollectionViewLayout()
    )

    override func setup() {
        super.setup()
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            GvaGalleryCardCell.self,
            forCellWithReuseIdentifier: GvaGalleryCardCell.identifier
        )

        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isAccessibilityElement = false
        accessibilityElements = [collectionView]

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])

        addSubview(operatorImageView)
        operatorImageView.layoutInSuperview(
            edges: [.bottom, .leading],
            insets: operatorImageInsets
        ).activate()
        operatorImageView.match(
            [.width, .height],
            value: .operatorImageSide
        ).activate()
    }

    override func defineLayout() {
        super.defineLayout()
        collectionView.backgroundColor = UIColor.clear
    }

    // MARK: - Initialization

    init(environment: Environment) {
        self.environment = environment
        super.init()
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    // MARK: - Internal

    func setOperatorImage(fromUrl url: String?, animated: Bool) {
        operatorImageView.setOperatorImage(fromUrl: url, animated: animated)
    }
}

// MARK: - Private

private extension GvaGalleryListView {
    func renderProps() {
        collectionView.reloadData()
    }

    func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(.cardWidth),
            heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = .init(
            top: sectionInsets.top,
            leading: sectionInsets.left,
            bottom: sectionInsets.bottom,
            trailing: sectionInsets.right
        )
        section.interGroupSpacing = 16
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource

extension GvaGalleryListView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        props.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GvaGalleryCardCell.identifier,
                for: indexPath
              ) as? GvaGalleryCardCell
        else { return UICollectionViewCell() }
        cell.props = props.items[indexPath.item]
        return cell
    }
}

// MARK: - Props

extension GvaGalleryListView {
    struct Props {
        let items: [GvaGalleryCardView.Props]
        let style: GvaGalleryListViewStyle

        static var nop: Props { .init(items: [], style: .initial) }
    }
}
