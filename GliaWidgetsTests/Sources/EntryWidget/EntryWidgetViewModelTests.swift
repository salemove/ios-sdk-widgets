import XCTest
import Combine
import GliaCoreSDK

@testable import GliaWidgets

class EntryWidgetViewModelTests: XCTestCase {
    func test_showPoweredBy() {
        let entryWidget = EntryWidget.mock()
        
        let viewModel = EntryWidgetView.Model(
            theme: .mock(showsPoweredBy: true),
            showHeader: true,
            configuration: .mock(showPoweredBy: true),
            viewStatePublisher: entryWidget.$viewState,
            mediaTypeSelected: { _ in }
        )
        
        XCTAssertTrue(viewModel.showPoweredBy)
    }
    
    func test_doesNotShowPoweredByUsingThemeProperty() {
        let entryWidget = EntryWidget.mock()
        
        let viewModel = EntryWidgetView.Model(
            theme: .mock(showsPoweredBy: false),
            showHeader: true,
            configuration: .mock(showPoweredBy: true),
            viewStatePublisher: entryWidget.$viewState,
            mediaTypeSelected: { _ in }
        )
        
        XCTAssertFalse(viewModel.showPoweredBy)
    }
    
    func test_doesNotShowPoweredByUsingConfigurationProperty() {
        let entryWidget = EntryWidget.mock()
        
        let viewModel = EntryWidgetView.Model(
            theme: .mock(showsPoweredBy: true),
            showHeader: true,
            configuration: .mock(showPoweredBy: false),
            viewStatePublisher: entryWidget.$viewState,
            mediaTypeSelected: { _ in }
        )
        
        XCTAssertFalse(viewModel.showPoweredBy)
    }
    
    func test_viewModelUsesDefaultStyleFromTheme() {
        let entryWidget = EntryWidget.mock()
        let theme = Theme.mock()
        let viewModel = EntryWidgetView.Model(
            theme: theme,
            showHeader: true,
            configuration: .mock(showPoweredBy: true),
            viewStatePublisher: entryWidget.$viewState,
            mediaTypeSelected: { _ in }
        )
        
        XCTAssertEqual(
            viewModel.style.mediaTypeItem,
            theme.chatStyle.secureMessagingExpandedTopBannerItemsStyle.mediaItemStyle
        )
        XCTAssertEqual(
            viewModel.style.dividerColor,
            theme.chatStyle.secureMessagingExpandedTopBannerItemsStyle.dividerColor
        )
    }
    
    func test_viewModelUsesConfiguredMediaTypeItemsStyle() {
        let entryWidget = EntryWidget.mock()
        let theme = Theme.mock()
        let mockStyle = EntryWidgetStyle.MediaTypeItemsStyle.mock()
        let viewModel = EntryWidgetView.Model(
            theme: theme,
            showHeader: true,
            configuration: .mock(showPoweredBy: true, mediaTypeItemsStyle: mockStyle),
            viewStatePublisher: entryWidget.$viewState,
            mediaTypeSelected: { _ in }
        )
        
        XCTAssertEqual(viewModel.style.mediaTypeItem, mockStyle.mediaItemStyle)
        XCTAssertEqual(viewModel.style.dividerColor, mockStyle.dividerColor)
        XCTAssertNotEqual(
            viewModel.style.mediaTypeItem,
            theme.chatStyle.secureMessagingExpandedTopBannerItemsStyle.mediaItemStyle
        )
        XCTAssertNotEqual(
            viewModel.style.dividerColor,
            theme.chatStyle.secureMessagingExpandedTopBannerItemsStyle.dividerColor
        )
    }
}
