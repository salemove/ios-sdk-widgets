import SwiftUI

extension EntryWidgetView {
    class Model: ObservableObject {
        let theme: Theme
        let channelSelected: (EntryWidget.Channel) -> Void
        let channels: [EntryWidget.Channel]
        let sizeConstraints: EntryWidget.SizeConstraints
        let showHeader: Bool

        var style: EntryWidgetStyle {
            theme.entryWidgetStyle
        }

        var showPoweredBy: Bool {
            // Once EntryWidget will be displayed in Secure
            // Conversations, additional checks will be added here
            guard theme.showsPoweredBy else { return false }

            return true
        }

        init(
            theme: Theme,
            showHeader: Bool,
            sizeConstrainsts: EntryWidget.SizeConstraints,
            channels: [EntryWidget.Channel],
            channelSelected: @escaping (EntryWidget.Channel) -> Void
        ) {
            self.theme = theme
            self.sizeConstraints = sizeConstrainsts
            self.showHeader = showHeader
            self.channels = channels
            self.channelSelected = channelSelected
        }
    }
}

extension EntryWidgetView.Model {
    func selectChannel(_ channel: EntryWidget.Channel) {
        channelSelected(channel)
    }
}
