import SwiftUI

extension EntryWidgetView {
    class Model: ObservableObject {
        let style: EntryWidgetStyle
        let channelSelected: (EntryWidget.Channel) -> Void
        let channels: [EntryWidget.Channel]
        let sizeConstraints: EntryWidget.SizeConstraints

        init(
            style: EntryWidgetStyle,
            sizeConstrainsts: EntryWidget.SizeConstraints,
            channels: [EntryWidget.Channel],
            channelSelected: @escaping (EntryWidget.Channel) -> Void
        ) {
            self.style = style
            self.sizeConstraints = sizeConstrainsts
            self.channels = channels
            self.channelSelected = channelSelected
        }

        func selectChannel(_ channel: EntryWidget.Channel) {
            channelSelected(channel)
        }
    }
}
