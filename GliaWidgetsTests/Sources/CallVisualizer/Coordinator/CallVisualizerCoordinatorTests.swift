import Foundation
import XCTest
@testable import GliaWidgets

final class CallVisualizerCoordinatorTests: XCTestCase {
    var coordinator: CallVisualizer.Coordinator!
    var viewController = UIViewController()

    override func setUp() {
        coordinator = .init(environment: .mock)
    }

    func test_showVisitorCodeViewController() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        coordinator.showVisitorCodeViewController(by: .alert(viewController))
        
        XCTAssertTrue(viewController.presentedViewController is CallVisualizer.VisitorCodeViewController)
    }

    func test_handleAcceptedUpgrade() {
        var calledEvents: [CallVisualizer.Coordinator.DelegateEvent] = []
        coordinator.environment.eventHandler = { calledEvents.append($0) }
        coordinator.handleAcceptedUpgrade()

        XCTAssertTrue(calledEvents.contains(.maximized))
    }

    func test_handleEngagementRequestAccepted() throws {
        let site = CoreSdkClient.Site(
            id: .mock, defaultOperatorPicture: nil,
            alwaysUseDefaultOperatorPicture: false,
            allowedFileSenders: try .mock(),
            maskingRegularExpressions: [],
            visitorAppDefaultLocale: "",
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true,
            mobileObservationVideoFps: try videoFps(),
            mobileObservationEnabled: true
        )

        coordinator.environment.fetchSiteConfigurations = { callback in
            callback(.success(site))
        }

        var answers: [Bool] = []
        let answer = Command<Bool> { boolean in
            answers.append(boolean)
        }

        coordinator.handleEngagementRequestAccepted(answer)
        XCTAssertEqual(answers, [true])
    }

    func test_handleEngagementRequestAcceptedMobileConfirmDialogEnabled() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        let presenter = CallVisualizer.Presenter(presenter: { self.viewController })
        coordinator.environment.presenter = presenter

        let site = CoreSdkClient.Site(
            id: .mock, defaultOperatorPicture: nil,
            alwaysUseDefaultOperatorPicture: false,
            allowedFileSenders: try .mock(),
            maskingRegularExpressions: [],
            visitorAppDefaultLocale: "",
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true,
            mobileObservationVideoFps: try videoFps(),
            mobileObservationEnabled: true
        )

        coordinator.environment.fetchSiteConfigurations = { callback in
            callback(.success(site))
        }

        let answer = Command<Bool> { _ in }
        coordinator.handleEngagementRequestAccepted(answer)

        XCTAssertTrue(coordinator.environment.presenter.getInstance()?.presentedViewController is AlertViewController)
    }

    func test_end() {
        var stopCallCounter = 0
        coordinator.environment.screenShareHandler.stop = { _ in
            stopCallCounter += 1
        }

        coordinator.end()

        XCTAssertEqual(stopCallCounter, 1)
    }

    func test_showSnackBarIfNeeded() throws {
        let site = CoreSdkClient.Site(
            id: .mock, defaultOperatorPicture: nil,
            alwaysUseDefaultOperatorPicture: false,
            allowedFileSenders: try .mock(),
            maskingRegularExpressions: [],
            visitorAppDefaultLocale: "",
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true,
            mobileObservationVideoFps: try videoFps(),
            mobileObservationEnabled: true
        )

        coordinator.environment.fetchSiteConfigurations = { callback in
            callback(.success(site))
        }
        
        var presentCallCounter = 0
        coordinator.environment.snackBar.present = { (_, _, _, _, _, _, _) in
            presentCallCounter += 1
        }

        coordinator.showSnackBarIfNeeded()

        XCTAssertEqual(presentCallCounter, 1)
    }

    private func videoFps() throws -> CoreSdkClient.Site.VideoFps {
        let jsonDecoder = JSONDecoder()
        let json = ["unlimited": 30, "metered": 30]
        let data = try JSONSerialization.data(withJSONObject: json)

        return try jsonDecoder.decode(
            CoreSdkClient.Site.VideoFps.self,
            from: data
        )
    }
}
