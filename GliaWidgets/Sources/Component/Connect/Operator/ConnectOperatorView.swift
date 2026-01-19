import SwiftUI

struct ConnectOperatorView: View {
    @State private var displayedImage: UIImage?
    @StateObject private var loader: RemoteImageLoader
    let style: ConnectOperatorStyle
    let state: EngagementState
    let environment: Environment
    private let avatarSide: CGFloat = 80
    private var ringSide: CGFloat = 116
    private let placeholderIconSize = CGSize(width: 32, height: 40)
    private var slotSide: CGFloat {
        switch state {
        case .connected, .onHold: return 80
        default: return 116
        }
    }

    init(
        style: ConnectOperatorStyle,
        state: EngagementState,
        environment: Environment
    ) {
        self.style = style
        self.state = state
        self.environment = environment
        _loader = StateObject(
            wrappedValue: RemoteImageLoader(
                environment: .init(
                    cache: environment.imageCache
                )
            )
        )
    }

    var body: some View {
        Group {
            switch state {
            case .initial:
                EmptyView()
            case .queue:
                content(
                    image: nil,
                    placeholder: style.operatorImage.placeholderImage,
                    showPulse: true,
                    showOnHoldOverlay: false
                )
                .onAppear { loader.cancel() }
            case .connecting(_, let url):
                content(
                    image: displayedImage ?? loader.image,
                    placeholder: style.operatorImage.placeholderImage,
                    showPulse: true,
                    showOnHoldOverlay: false
                )
                .onAppear { loader.load(from: url) }
            case .connected(_, let url):
                content(
                    image: displayedImage ?? loader.image,
                    placeholder: style.operatorImage.placeholderImage,
                    showPulse: false,
                    showOnHoldOverlay: false
                )
                .onAppear { loader.load(from: url) }
            case .transferring:
                content(
                    image: nil,
                    placeholder: style.operatorImage.transferringImage
                        ?? style.operatorImage.placeholderImage,
                    showPulse: true,
                    showOnHoldOverlay: false
                )
                .onAppear { loader.cancel() }
            case .onHold(_, let url, _, _):
                content(
                    image: displayedImage ?? loader.image,
                    placeholder: style.operatorImage.placeholderImage,
                    showPulse: false,
                    showOnHoldOverlay: true
                )
                .onAppear { loader.load(from: url) }
            }
        }
        .width(slotSide)
        .height(slotSide)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(style.accessibility.label)
        .accessibilityHint(style.accessibility.hint)
        .accessibilityAddTraits(.isImage)
        .onChange(of: state) { newValue in
            switch newValue {
            case .connecting(_, let url),
                 .connected(_, let url),
                 .onHold(_, let url, _, _):
                loader.load(from: url)
            case .queue, .transferring:
                displayedImage = nil
                loader.cancel()
            case .initial:
                break
            }
        }
        .onReceive(loader.$image) { newImage in
            if let newImage {
                displayedImage = newImage
            }
        }
    }

    @ViewBuilder
    private func content(
        image: UIImage?,
        placeholder: UIImage?,
        showPulse: Bool,
        showOnHoldOverlay: Bool
    ) -> some View {
        ZStack {
            if showPulse {
                ConnectPulseRings(color: style.animationColor)
                    .width(ringSide)
                    .height(ringSide)
            }
            avatar(
                image: image,
                placeholder: placeholder
            )
            .overlay {
                if showOnHoldOverlay {
                    OnHoldOverlay(style: style.onHoldOverlay)
                }
            }
        }
    }

    @ViewBuilder
    private func avatar(
        image: UIImage?,
        placeholder: UIImage?
    ) -> some View {
        ZStack {
            if image != nil {
                Background(style.operatorImage.imageBackgroundColor)
            } else {
                Background(style.operatorImage.placeholderBackgroundColor)
            }
            if let image {
                SwiftUI.Image(uiImage: image)
                    .resizable()
                    .fill()
            } else if let placeholder {
                SwiftUI.Image(uiImage: placeholder)
                    .renderingMode(.template)
                    .resizable()
                    .fit()
                    .width(placeholderIconSize.width)
                    .height(placeholderIconSize.height)
                    .setColor(style.operatorImage.placeholderColor)
            }
        }
        .width(avatarSide)
        .height(avatarSide)
        .clipShape(.circle)
    }
}
