import UIKit
import XCTest
@testable import GliaWidgets

extension CallVisualizerTests {
    func testLiveObservationIndicatorIsPresentedOnEngagementRequest() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.async = { $0() }
        var interactable: CoreSdkClient.Interactable?
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { interactor in
            interactable = interactor
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        gliaEnv.snackBar.present = { _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })
        sdk.callVisualizer.delegate?(.visitorCodeIsRequested)

        interactable?.onEngagementRequest({ _, _, _ in })

        XCTAssertEqual(calls, [.presentSnackBar])
    }

    func testLiveObservationIndicatorIsPresentedOnEngagementRestore() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.snackBar.present = { _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { completion in
            completion(.success(site))
        }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        let sdk = Glia(environment: gliaEnv)
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            sdk.environment.coreSdk.getCurrentEngagement = {
                .mock(source: .callVisualizer)
            }
            completion(.success(()))
        }
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        XCTAssertEqual(calls, [.presentSnackBar])
    }
}
