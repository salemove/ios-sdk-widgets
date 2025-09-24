import UIKit
import XCTest
@testable import GliaWidgets

extension CallVisualizerTests {
    func testLiveObservationIndicatorIsPresentedOnEngagementRequest() async throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []
        
        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { site }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.async = { $0() }
        var interactable: CoreSdkClient.Interactable?
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { interactor in
            interactable = interactor
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        let request = CoreSdkClient.Request.init(id: "123", outcome: .accepted, platform: nil)
        interactable?.onEngagementRequest(request, { _, _, _ in })

        // Will be removed when async state observing is implemented
        await waitUntil {
            calls == [.presentSnackBar]
        }

        XCTAssertEqual(calls, [.presentSnackBar])
    }

    func testLiveObservationIndicationIsDisabledOnEngagementRequest() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: false
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { site }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.async = { $0() }
        var interactable: CoreSdkClient.Interactable?
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { interactor in
            interactable = interactor
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        let request = CoreSdkClient.Request.init(id: "123", outcome: .accepted, platform: nil)
        interactable?.onEngagementRequest(request, { _, _, _ in })

        XCTAssertEqual(calls, [])
    }

    func testLiveObservationIsDisabledOnEngagementRequest() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: false,
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { site }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.async = { $0() }
        var interactable: CoreSdkClient.Interactable?
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { interactor in
            interactable = interactor
        }
        gliaEnv.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.success(()))
        }
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        let request = CoreSdkClient.Request.init(id: "123", outcome: .accepted, platform: nil)
        interactable?.onEngagementRequest(request, { _, _, _ in })

        XCTAssertEqual(calls, [])
    }

    func testLiveObservationIndicatorIsPresentedOnEngagementRestore() async throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: false,
            mobileObservationIndicationEnabled: true
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { site }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            sdk.environment.coreSdk.getCurrentEngagement = {
                .mock(source: .callVisualizer)
            }
            completion(.success(()))
        }
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        // Will be removed when async state observing is implemented
        await waitUntil {
            calls == [.presentSnackBar]
        }

        XCTAssertEqual(calls, [.presentSnackBar])
    }

    func testLiveObservationIndicationIsDisabledOnEngagementRestore() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: true,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: false
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { site }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            sdk.environment.coreSdk.getCurrentEngagement = {
                .mock(source: .callVisualizer)
            }
            completion(.success(()))
        }
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        XCTAssertEqual(calls, [])
    }

    func testLiveObservationIsDisabledOnEngagementRestore() throws {
        enum Call { case presentSnackBar }
        var calls: [Call] = []

        var gliaEnv = Glia.Environment.failing
        gliaEnv.conditionalCompilation.isDebug = { true }
        var snackBar: SnackBar = .mock
        snackBar.present = { _, _, _, _, _, _, _ in
            calls.append(.presentSnackBar)
        }
        DependencyContainer.current.widgets.snackBar = snackBar
        gliaEnv.coreSdk.createLogger = { _ in .mock }
        let site = try CoreSdkClient.Site.mock(
            mobileObservationEnabled: false,
            mobileConfirmDialogEnabled: true,
            mobileObservationIndicationEnabled: true
        )
        gliaEnv.coreSdk.fetchSiteConfigurations = { site }
        gliaEnv.callVisualizerPresenter = .init(presenter: { nil })
        gliaEnv.gcd.mainQueue.asyncIfNeeded = { $0() }
        gliaEnv.coreSDKConfigurator.configureWithInteractor = { _ in }
        gliaEnv.coreSdk.secureConversations.observePendingStatus = { _ in nil }
        let sdk = Glia(environment: gliaEnv)
        sdk.environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            sdk.environment.coreSdk.getCurrentEngagement = {
                .mock(source: .callVisualizer)
            }
            completion(.success(()))
        }
        try sdk.configure(with: .mock(), theme: .mock(), completion: { _ in })

        XCTAssertEqual(calls, [])
    }
}
