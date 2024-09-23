import SwiftUI

struct EntryWidgetView: View {
    @StateObject var model: Model

    var body: some View {
        VStack(spacing: 0) {
            headerView()
            channelsView()
            poweredByView()
        }
        .maxSize()
        .padding(.horizontal)
    }
}

private extension EntryWidgetView {
    @ViewBuilder
    func channelsView() -> some View {
        VStack(spacing: 0) {
            ForEach(model.channels.indices, id: \.self) { index in
                channelCell(channel: model.channels[index])
                Divider()
                    .height(model.sizeConstraints.dividerHeight)
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
                .fill(model.style.draggerColor.swiftUIColor())
                .width(model.sizeConstraints.sheetHeaderDraggerWidth)
                .height(model.sizeConstraints.sheetHeaderDraggerHeight)
        }
        .maxWidth()
        .height(model.sizeConstraints.sheetHeaderHeight)
    }

    @ViewBuilder
    func channelCell(channel: EntryWidget.Channel) -> some View {
        HStack(spacing: 16) {
            icon(channel.image)
            VStack(alignment: .leading, spacing: 2) {
                headlineText(channel.headline)
                subheadlineText(channel.subheadline)
            }
        }
        .maxWidth(alignment: .leading)
        .height(model.sizeConstraints.singleCellHeight)
        .contentShape(.rect)
        .onTapGesture {
            model.selectChannel(channel)
        }
    }

    @ViewBuilder
    func icon(_ image: UIImage) -> some View {
        image.asSwiftUIImage()
            .resizable()
            .fit()
            .width(model.sizeConstraints.singleCellIconSize)
            .height(model.sizeConstraints.singleCellIconSize)
            .setColor(model.style.channel.iconColor.swiftUIColor())
    }

    @ViewBuilder
    func headlineText(_ label: String) -> some View {
        Text(label)
            .font(.convert(model.style.channel.headlineFont))
            .setColor(model.style.channel.headlineColor.swiftUIColor())
    }

    @ViewBuilder
    func subheadlineText(_ label: String) -> some View {
        Text(label)
            .font(.convert(model.style.channel.subheadlineFont))
            .setColor(model.style.channel.subheadlineColor.swiftUIColor())
    }
}
