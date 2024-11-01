import AccessibilitySnapshot
import Combine
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class EntryWidgetViewDynamicTypeFontTests: SnapshotTestCase {
    func testEntryWidgetWhenLoading() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .loading
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenLoading() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .loading
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetWhenError() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .error
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenError() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .error
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetWhenOffline() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .offline
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenOffline() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .offline
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetWhenFourMediaTypes() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .mediaTypes([.video, .audio, .chat, .secureMessaging])
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenFourMediaTypes() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .mediaTypes([.video, .audio, .chat, .secureMessaging])
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetWhenThreeMediaTypes() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .mediaTypes([.video, .audio, .chat])
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenThreeMediaTypes() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .mediaTypes([.video, .audio, .chat])
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetWhenTwoMediaTypes() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .mediaTypes([.video, .audio])
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenTwoMediaTypes() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .mediaTypes([.video, .audio])
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetWhenOneMediaTypes() {
        let entryWidget: EntryWidget = .mock()
        entryWidget.show(in: .init())
        entryWidget.viewState = .mediaTypes([.video])
        let height = entryWidget.calculateHeight()
        let view = entryWidget.hostedViewController?.view
        view?.frame = viewControllerFrame(height: height)
        view?.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view?.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func testEntryWidgetEmbeddedWhenOneMediaTypes() {
        let entryWidget: EntryWidget = .init(queueIds: [], environment: .mock())
        let view = UIView()
        entryWidget.embed(in: view)
        entryWidget.viewState = .mediaTypes([.video])
        let height = entryWidget.calculateHeight()
        view.frame = viewControllerFrame(height: height)
        view.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        view.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}

private extension EntryWidgetViewDynamicTypeFontTests {
    func viewControllerFrame(height: CGFloat) -> CGRect {
        .init(
            origin: .zero,
            size: .init(
                width: UIScreen.main.bounds.width,
                height: height
            )
        )
    }
}
