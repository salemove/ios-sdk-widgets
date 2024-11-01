import SwiftUI

extension EntryWidgetView {
    class Model: ObservableObject {
        @Published var viewState: EntryWidget.ViewState = .loading
        let theme: Theme
        let mediaTypeSelected: (EntryWidget.MediaTypeItem) -> Void
        let sizeConstraints: EntryWidget.SizeConstraints
        let showHeader: Bool
        var retryMonitoring: (() -> Void)?
        var style: EntryWidgetStyle {
            theme.entryWidget
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
            sizeConstraints: EntryWidget.SizeConstraints,
            viewStatePublisher: Published<EntryWidget.ViewState>.Publisher,
            mediaTypeSelected: @escaping (EntryWidget.MediaTypeItem) -> Void
        ) {
            self.theme = theme
            self.showHeader = showHeader
            self.sizeConstraints = sizeConstraints
            self.mediaTypeSelected = mediaTypeSelected

            viewStatePublisher.assign(to: &$viewState)
        }

        func selectMediaType(_ mediaTypeItem: EntryWidget.MediaTypeItem) {
            mediaTypeSelected(mediaTypeItem)
        }

        func onTryAgainTapped() {
            retryMonitoring?()
        }
    }
}
