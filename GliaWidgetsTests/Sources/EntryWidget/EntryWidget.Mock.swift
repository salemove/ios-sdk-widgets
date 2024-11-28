@testable import GliaWidgets

extension EntryWidget.Configuration {
    static func mock(
        sizeConstraint: EntryWidget.SizeConstraints? = nil,
        showPoweredBy: Bool? = nil,
        filterSecureConversation: Bool? = nil,
        mediaTypeSelected: Command<EntryWidget.MediaTypeItem>? = nil
    ) -> Self {
        Self(
            sizeConstraints: sizeConstraint ?? .init(
                singleCellHeight: 72,
                singleCellIconSize: 24,
                poweredByContainerHeight: 40,
                sheetHeaderHeight: 36,
                sheetHeaderDraggerWidth: 32,
                sheetHeaderDraggerHeight: 4,
                dividerHeight: 1,
                dividerHorizontalPadding: nil
            ),
            showPoweredBy: showPoweredBy ?? true,
            filterSecureConversation: filterSecureConversation ?? false,
            mediaTypeSelected: mediaTypeSelected
        )
    }
}
