import SwiftUI

extension EntryWidgetView {
    class Model: ObservableObject {
        @Published var viewState: ViewState
        @Published var channels: [EntryWidget.Channel] = []
        let theme: Theme
        let channelSelected: (EntryWidget.Channel) throws -> Void
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
            channels: Published<[EntryWidget.Channel]>.Publisher,
            channelSelected: @escaping (EntryWidget.Channel) throws -> Void
        ) {
            self.theme = theme
            self.sizeConstraints = sizeConstrainsts
            self.showHeader = showHeader
            self.channelSelected = channelSelected
            self.viewState = .mediaTypes

            channels.assign(to: &self.$channels)
        }
    }
}

extension EntryWidgetView.Model {
    func selectChannel(_ channel: EntryWidget.Channel) {
        do {
            try channelSelected(channel)
        } catch {
            // TODO: Distinguish errors on View if needed 
            viewState = .error
        }
    }

    func onTryAgainTapped() {
        // The logic will be added together with EngagementLauncher integration
        print("Try again button tapped")
    }
}

extension EntryWidgetView.Model {
    enum ViewState {
        case error
        case loading
        case mediaTypes
        case offline
    }
}
