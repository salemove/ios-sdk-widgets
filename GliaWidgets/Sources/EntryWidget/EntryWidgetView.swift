import SwiftUI

struct EntryWidgetView: View {
    @SwiftUI.Environment(\.sizeCategory) var sizeCategory

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
                Text(model.style.errorTitle)
                    .setFont(model.style.errorTitleFont)
                    .setColor(model.style.errorTitleColor)
                    .accessibilityIdentifier("entryWidget_error_title")
                Text(model.style.errorMessage)
                    .setFont(model.style.errorMessageFont)
                    .setColor(model.style.errorMessageColor)
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
                [
                    .init(type: .secureMessaging),
                    .init(type: .secureMessaging),
                    .init(type: .secureMessaging),
                    .init(type: .secureMessaging)
                ],
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
        .applyColorTypeBackground(model.style.backgroundColor)
        .accessibilityIdentifier("entryWidget_loading")
    }

    @ViewBuilder
    func mediaTypesView(_ types: [EntryWidget.MediaTypeItem]) -> some View {
        VStack(spacing: 0) {
            if model.showHeader {
                headerView()
                    .padding(.horizontal)
            }
            mediaTypes(types)
            if model.showPoweredBy {
                poweredByView()
                    .padding(.horizontal)
            }
        }
        .maxSize()
        .applyColorTypeBackground(model.style.backgroundColor)
    }

    @ViewBuilder
    func offilineView() -> some View {
        VStack(spacing: 0) {
            if model.showHeader {
                headerView()
            }
            VStack(spacing: 16) {
                Text(model.style.offlineTitle)
                    .setFont(model.style.errorTitleFont)
                    .setColor(model.style.errorTitleColor)
                    .accessibilityIdentifier("entryWidget_offline_title")
                Text(model.style.offlineMessage)
                    .setFont(model.style.errorMessageFont)
                    .setColor(model.style.errorMessageColor)
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
                Group {
                    if isPlaceholder {
                        placeholderMediaTypeCell(mediaType: types[index])
                    } else {
                        mediaTypeCell(mediaType: types[index])
                    }
                }
                .padding(.horizontal)

                Divider()
                    .height(model.configuration.sizeConstraints.dividerHeight)
                    .setColor(model.style.dividerColor)
                    .padding(.horizontal, model.configuration.sizeConstraints.dividerHorizontalPadding)
            }
        }
    }

    @ViewBuilder
    func poweredByView() -> some View {
        PoweredByView(
            style: model.style.poweredBy,
            containerHeight: model.configuration.sizeConstraints.poweredByContainerHeight
        )
    }

    @ViewBuilder
    func headerView() -> some View {
        VStack {
            Capsule(style: .continuous)
                .fill(model.style.dividerColor.swiftUIColor())
                .width(model.configuration.sizeConstraints.sheetHeaderDraggerWidth)
                .height(model.configuration.sizeConstraints.sheetHeaderDraggerHeight)
        }
        .maxWidth()
        .height(model.configuration.sizeConstraints.sheetHeaderHeight)
    }

    @ViewBuilder
    func mediaTypeCell(mediaType: EntryWidget.MediaTypeItem) -> some View {
        HStack(spacing: 16) {
            icon(mediaType.image)
            VStack(alignment: .leading, spacing: 2) {
                headlineText(model.style.mediaTypeItem.title(for: mediaType))
                if !sizeCategory.isAccessibilityCategory {
                    subheadlineText(model.style.mediaTypeItem.message(for: mediaType))
                }
            }
            unreadMessageCountView(for: mediaType)
        }
        .maxWidth(alignment: .leading)
        .height(model.configuration.sizeConstraints.singleCellHeight)
        .applyColorTypeBackground(model.style.mediaTypeItem.backgroundColor)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibility(addTraits: .isButton)
        .accessibilityHint(model.style.mediaTypeItem.accessibility.hint(for: mediaType))
        .accessibilityIdentifier("entryWidget_\(mediaType.type)_item")
        .onTapGesture {
            model.selectMediaType(mediaType)
        }
    }

    @ViewBuilder
    func placeholderMediaTypeCell(mediaType: EntryWidget.MediaTypeItem) -> some View {
        HStack(spacing: 16) {
            Circle()
                .applyColorTypeForeground(model.style.mediaTypeItem.loading.loadingTintColor)
                .width(model.configuration.sizeConstraints.singleCellIconSize)
                .height(model.configuration.sizeConstraints.singleCellIconSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.style.mediaTypeItem.title(for: mediaType))
                    .setFont(model.style.mediaTypeItem.titleFont)
                    .redactedPlaceholder(
                        model.style.mediaTypeItem.loading.loadingTintColor,
                        font: model.style.mediaTypeItem.titleFont
                    )
                Text(model.style.mediaTypeItem.message(for: mediaType))
                    .setFont(model.style.mediaTypeItem.messageFont)
                    .redactedPlaceholder(
                        model.style.mediaTypeItem.loading.loadingTintColor,
                        font: model.style.mediaTypeItem.messageFont
                    )
            }
        }
        .maxWidth(alignment: .leading)
        .height(model.configuration.sizeConstraints.singleCellHeight)
        .applyColorTypeBackground(model.style.mediaTypeItem.backgroundColor)
        .contentShape(.rect)
        .disabled(true)
    }

    @ViewBuilder
    func icon(_ image: UIImage) -> some View {
        image.asSwiftUIImage()
            .resizable()
            .fit()
            .width(model.configuration.sizeConstraints.singleCellIconSize)
            .height(model.configuration.sizeConstraints.singleCellIconSize)
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
            .accessibilityIdentifier("entryWidget_error_button")
    }

    @ViewBuilder
    func unreadMessageCountView(for mediaType: EntryWidget.MediaTypeItem) -> some View {
        if mediaType.badgeCount > 0 {
            Spacer()
            Text("\(mediaType.badgeCount)")
                .setFont(model.style.mediaTypeItem.unreadMessagesCounterFont)
                .setColor(model.style.mediaTypeItem.unreadMessagesCounterColor)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .applyColorTypeBackground(model.style.mediaTypeItem.unreadMessagesCounterBackgroundColor)
                .clipShape(Circle())
        }
    }
}
