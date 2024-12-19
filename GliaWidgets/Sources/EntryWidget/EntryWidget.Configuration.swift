import Foundation

extension EntryWidget {
    struct SizeConstraints {
        let singleCellHeight: CGFloat
        let singleCellIconSize: CGFloat
        let poweredByContainerHeight: CGFloat
        let sheetHeaderHeight: CGFloat
        let sheetHeaderDraggerWidth: CGFloat
        let sheetHeaderDraggerHeight: CGFloat
        let dividerHeight: CGFloat
        // Passing `nil` will set default value of 16 on View
        let dividerHorizontalPadding: CGFloat?
    }
}

extension EntryWidget {
    struct Configuration {
        let sizeConstraints: EntryWidget.SizeConstraints
        let showPoweredBy: Bool
        let filterSecureConversation: Bool
        let mediaTypeSelected: Command<EntryWidget.MediaTypeItem>?
        let mediaTypeItemsStyle: EntryWidgetStyle.MediaTypeItemsStyle?
    }
}

extension EntryWidget.Configuration {
    static let `default` = Self(
        sizeConstraints: .init(
            singleCellHeight: 72,
            singleCellIconSize: 24,
            poweredByContainerHeight: 40,
            sheetHeaderHeight: 36,
            sheetHeaderDraggerWidth: 32,
            sheetHeaderDraggerHeight: 4,
            dividerHeight: 1,
            dividerHorizontalPadding: nil
        ),
        showPoweredBy: true,
        filterSecureConversation: false,
        mediaTypeSelected: nil,
        mediaTypeItemsStyle: nil
    )
}
