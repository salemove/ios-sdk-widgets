import SwiftUI

extension EntryWidgetView {
    class Model: ObservableObject {
        @Published var viewState: EntryWidget.ViewState = .loading
        let theme: Theme
        let mediaTypeSelected: (EntryWidget.MediaTypeItem) -> Void
        let configuration: EntryWidget.Configuration
        let showHeader: Bool
        var retryMonitoring: (() -> Void)?

        var style: EntryWidgetStyle {
            if let mediaTypeItemsStyle = configuration.mediaTypeItemsStyle {
                var widgetStyle = theme.entryWidgetStyle
                widgetStyle.mediaTypeItem = mediaTypeItemsStyle.mediaItemStyle
                widgetStyle.dividerColor = mediaTypeItemsStyle.dividerColor
                return widgetStyle
            } else {
                return theme.entryWidgetStyle
            }
        }

        var showPoweredBy: Bool {
            theme.showsPoweredBy && configuration.showPoweredBy
        }

        init(
            theme: Theme,
            showHeader: Bool,
            configuration: EntryWidget.Configuration,
            viewStatePublisher: Published<EntryWidget.ViewState>.Publisher,
            mediaTypeSelected: @escaping (EntryWidget.MediaTypeItem) -> Void
        ) {
            self.theme = theme
            self.showHeader = showHeader
            self.configuration = configuration
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
