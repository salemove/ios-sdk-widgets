import SwiftUI

struct EntryWidgetView: View {
    @StateObject var model: Model

    var body: some View {
        switch model.viewState {
        case .error:
            errorView()
        case .loading:
            loadingView()
        case let .mediaTypes(types):
            mediaTypesView(types)
        case .offline:
            offilineView()
        }
    }
}

// MARK: - View States
private extension EntryWidgetView {
    @ViewBuilder
    func errorView() -> some View {
        VStack(spacing: 0) {
            if model.showHeader {
                headerView()
            }
            VStack(spacing: 16) {
                Text(Localization.EntryWidget.ErrorState.title)
                    .setFont(model.style.errorTitleFont)
                    .setColor(model.style.errorTitleColor)
                Text(Localization.EntryWidget.ErrorState.description)
                    .setFont(model.style.errorMessageFont)
                    .setColor(model.style.errorTitleColor)
                errorButton()
            }
            .maxHeight()
            if model.showPoweredBy {
                poweredByView()
            }
        }
        .maxSize()
        .padding(.horizontal)
        .applyColorTypeBackground(model.style.backgroundColor)
    }

    @ViewBuilder
    func loadingView() -> some View {
        VStack(spacing: 0) {
            if model.showHeader {
                headerView()
            }
            mediaTypes(
                [.secureMessaging, .secureMessaging, .secureMessaging, .secureMessaging],
                isPlaceholder: true
            )
            .redacted(reason: .placeholder)
            .accessibility(hidden: false)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(model.style.mediaTypeItem.loading.accessibility.label)
            if model.showPoweredBy {
                poweredByView()
            }
        }
        .maxSize()
        .padding(.horizontal)
        .applyColorTypeBackground(model.style.backgroundColor)
    }

    @ViewBuilder
    func mediaTypesView(_ types: [EntryWidget.MediaTypeItem]) -> some View {
        VStack(spacing: 0) {
            if model.showHeader {
                headerView()
            }
            mediaTypes(types)
            if model.showPoweredBy {
                poweredByView()
            }
        }
        .maxSize()
        .padding(.horizontal)
        .applyColorTypeBackground(model.style.backgroundColor)
    }

    @ViewBuilder
    func offilineView() -> some View {
        VStack(spacing: 0) {
            if model.showHeader {
                headerView()
            }
            VStack(spacing: 16) {
                Text(Localization.EntryWidget.EmptyState.title)
                    .setFont(model.style.errorTitleFont)
                    .setColor(model.style.errorTitleColor)
                Text(Localization.EntryWidget.EmptyState.description)
                    .setFont(model.style.errorMessageFont)
                    .setColor(model.style.errorTitleColor)
            }
            .maxHeight()
            if model.showPoweredBy {
                poweredByView()
            }
        }
        .maxSize()
        .padding(.horizontal)
        .applyColorTypeBackground(model.style.backgroundColor)
    }
}

// MARK: - View Components
private extension EntryWidgetView {
    @ViewBuilder
    func mediaTypes(
        _ types: [EntryWidget.MediaTypeItem],
        isPlaceholder: Bool = false
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(types.indices, id: \.self) { index in
                if isPlaceholder {
                    placeholderMediaTypeCell(mediaType: types[index])
                } else {
                    mediaTypeCell(mediaType: types[index])
                }

                Divider()
                    .height(model.sizeConstraints.dividerHeight)
                    .setColor(model.style.dividerColor)
            }
        }
    }

    @ViewBuilder
    func poweredByView() -> some View {
        PoweredByView(
            style: model.style.poweredBy,
            containerHeight: model.sizeConstraints.poweredByContainerHeight
        )
    }

    @ViewBuilder
    func headerView() -> some View {
        VStack {
            Capsule(style: .continuous)
                .fill(model.style.dividerColor.swiftUIColor())
                .width(model.sizeConstraints.sheetHeaderDraggerWidth)
                .height(model.sizeConstraints.sheetHeaderDraggerHeight)
        }
        .maxWidth()
        .height(model.sizeConstraints.sheetHeaderHeight)
    }

    @ViewBuilder
    func mediaTypeCell(mediaType: EntryWidget.MediaTypeItem) -> some View {
        HStack(spacing: 16) {
            icon(mediaType.image)
            VStack(alignment: .leading, spacing: 2) {
                headlineText(mediaType.headline)
                subheadlineText(mediaType.subheadline)
            }
        }
        .maxWidth(alignment: .leading)
        .height(model.sizeConstraints.singleCellHeight)
        .applyColorTypeBackground(model.style.mediaTypeItem.backgroundColor)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibility(addTraits: .isButton)
        .accessibilityHint(mediaType.hintline)
        .onTapGesture {
            model.selectMediaType(mediaType)
        }
    }

    @ViewBuilder
    func placeholderMediaTypeCell(mediaType: EntryWidget.MediaTypeItem) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.baseShade.swiftUIColor().opacity(0.5))
                .width(model.sizeConstraints.singleCellIconSize)
                .height(model.sizeConstraints.singleCellIconSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(mediaType.headline)
                    .setFont(model.style.mediaTypeItem.titleFont)
                    .setColor(Color.baseNormal)
                Text(mediaType.subheadline)
                    .setFont(model.style.mediaTypeItem.messageFont)
                    .setColor(Color.baseNormal)
            }
        }
        .maxWidth(alignment: .leading)
        .height(model.sizeConstraints.singleCellHeight)
        .applyColorTypeBackground(model.style.mediaTypeItem.backgroundColor)
        .contentShape(.rect)
        .disabled(true)
    }

    @ViewBuilder
    func icon(_ image: UIImage) -> some View {
        image.asSwiftUIImage()
            .resizable()
            .fit()
            .width(model.sizeConstraints.singleCellIconSize)
            .height(model.sizeConstraints.singleCellIconSize)
            .applyColorTypeForeground(model.style.mediaTypeItem.iconColor)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    func headlineText(_ label: String) -> some View {
        Text(label)
            .setFont(model.style.mediaTypeItem.titleFont)
            .setColor(model.style.mediaTypeItem.titleColor)
    }

    @ViewBuilder
    func subheadlineText(_ label: String) -> some View {
        Text(label)
            .setFont(model.style.mediaTypeItem.messageFont)
            .setColor(model.style.mediaTypeItem.messageColor)
    }

    @ViewBuilder
    func errorButton() -> some View {
        Text(model.style.errorButton.title)
            .setFont(model.style.errorButton.titleFont)
            .setColor(model.style.errorButton.titleColor)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .clipShape(.rect(
                cornerRadius: model.style.errorButton.cornerRaidus ?? 0,
                style: .continuous
            ))
            .overlay(
                RoundedRectangle(cornerRadius: model.style.errorButton.cornerRaidus ?? 0)
                    .stroke(
                        model.style.errorButton.borderColor?.swiftUIColor() ?? .clear,
                        lineWidth: model.style.errorButton.borderWidth ?? 0
                    )
            )
            .shadow(
                color: model.style.errorButton.shadowColor?.swiftUIColor() ?? .clear,
                radius: model.style.errorButton.shadowRadius ?? 0,
                x: model.style.errorButton.shadowOffset?.width ?? 0,
                y: model.style.errorButton.shadowOffset?.height ?? 0
            )
            .contentShape(.rect)
            .onTapGesture(perform: model.onTryAgainTapped)
            .accessibility(addTraits: .isButton)
    }
}
