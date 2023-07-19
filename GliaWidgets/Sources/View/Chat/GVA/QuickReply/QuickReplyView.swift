import UIKit

final class QuickReplyView: BaseView {
    var props: Props = .hidden {
        didSet {
            renderProps()
        }
    }

    let style: GvaQuickReplyButtonStyle
    private lazy var collectionView: SelfSizingCollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        return SelfSizingCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
    }()
    private var collectionViewHeightConstraint: NSLayoutConstraint?

    init(style: GvaQuickReplyButtonStyle) {
        self.style = style
        super.init()
    }

    @available(*, unavailable)
    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()
        collectionView.register(
            QuickReplyButtonCell.self,
            forCellWithReuseIdentifier: QuickReplyButtonCell.identifier
        )
        collectionView.dataSource = self

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func defineLayout() {
        super.defineLayout()
        let height = collectionView.heightAnchor.constraint(equalToConstant: 0)
        height.priority = .required
        collectionViewHeightConstraint = height

        NSLayoutConstraint.activate([
            height,
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - Private

private extension QuickReplyView {
    func renderProps() {
        UIView.animate(withDuration: 0.3) {
            switch self.props {
            case .shown:
                self.collectionViewHeightConstraint?.priority = .defaultLow
            case .hidden:
                self.collectionViewHeightConstraint?.priority = .required
            }
            self.layoutIfNeeded()
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension QuickReplyView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        props.buttons?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let props = props.buttons,
              let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: QuickReplyButtonCell.identifier,
            for: indexPath
        ) as? QuickReplyButtonCell else {
            return UICollectionViewCell()
        }
        cell.style = style
        cell.props = props[indexPath.item]
        return cell
    }
}

// MARK: - Props

extension QuickReplyView {
    enum Props {
        case shown([QuickReplyButtonCell.Props])
        case hidden

        var buttons: [QuickReplyButtonCell.Props]? {
            switch self {
            case let .shown(buttons): return buttons
            case .hidden: return nil
            }
        }
    }
}
