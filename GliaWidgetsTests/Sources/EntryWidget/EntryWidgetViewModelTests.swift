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
}
