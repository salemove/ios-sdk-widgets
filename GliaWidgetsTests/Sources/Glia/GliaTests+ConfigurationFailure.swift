@_spi(GliaWidgets) internal import GliaCoreSDK
import XCTest

@testable import GliaWidgets

extension GliaTests {
    func test_configureLogsWarningWhenSiteSettingsRetrievalFails() async {
        let logs = await configureFailureLogs(for: CoreSdkClient.ConfigurationProcessError.siteSettingsRetrieval)

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: siteSettingsRetrieval")])
    }

    func test_configureLogsWarningWhenLocaleRetrievalFails() async {
        let logs = await configureFailureLogs(for: CoreSdkClient.ConfigurationProcessError.localeRetrieval)

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: localeRetrieval")])
    }

    func test_configureLogsWarningWhenLocaleIsEmpty() async {
        let logs = await configureFailureLogs(for: CoreSdkClient.ConfigurationProcessError.emptyLocale)

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: emptyLocale")])
    }

    func test_configureLogsWarningWhenNetworkErrorOccurs() async {
        let logs = await configureFailureLogs(for: CoreSdkClient.GeneralError.networkError)

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: networkError")])
    }

    func test_configureLogsErrorWhenInternalErrorOccurs() async {
        let logs = await configureFailureLogs(for: CoreSdkClient.GeneralError.internalError)

        XCTAssertEqual(logs, [.init(level: .error, message: "Glia Widgets SDK initialization failed: internalError")])
    }

    func test_configureLogsErrorWhenConfigurationIsInvalid() async {
        let logs = await configureFailureLogs(for: CoreSdkClient.ConfigurationError.invalidConfiguration)

        XCTAssertEqual(logs, [.init(level: .error, message: "Glia Widgets SDK initialization failed: invalidConfiguration")])
    }

    func test_configureLogsErrorWithTypeNameForUnknownError() async {
        struct SecretBearingError: Error {
            let secret = "s3cr3t"
        }

        let logs = await configureFailureLogs(for: SecretBearingError())

        XCTAssertEqual(logs, [.init(level: .error, message: "Glia Widgets SDK initialization failed: SecretBearingError")])
        XCTAssertFalse(logs.contains { $0.message.contains("s3cr3t") })
    }

    func test_configureLogsOtelWarningWhenConfigurationIsInvalid() async {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.debugClosure = { _, _, _, _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.errorClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            throw CoreSdkClient.ConfigurationError.invalidSite
        }

        var receivedError: Error?
        let warnings = await capturingOtelWarnings {
            let sdk = Glia(environment: environment)
            do {
                try await sdk.configure(with: .mock(), theme: .mock())
            } catch {
                receivedError = error
            }
        }

        XCTAssertEqual(
            warnings,
            [.init(event: .widgetsSdkConfigured, message: "Glia Widgets SDK initialization failed: invalidSite")]
        )
        XCTAssertEqual(receivedError as? GliaError, .internalError)
    }

    func test_configureDoesNotLogOtelWarningWhenConfigurationIsValid() async {
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.infoClosure = { _, _, _, _ in }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in }
        environment.conditionalCompilation.isDebug = { true }
        environment.coreSDKConfigurator.configureWithInteractor = { _ in }
        environment.coreSdk.secureConversations.pendingSecureConversationStatusStream = { AsyncThrowingStream { $0.finish() } }

        var isConfigured = false
        let warnings = await capturingOtelWarnings {
            let sdk = Glia(environment: environment)
            try? await sdk.configure(with: .mock(), theme: .mock())
            isConfigured = sdk.isConfigured
        }

        XCTAssertTrue(isConfigured)
        XCTAssertFalse(warnings.contains { $0.event == .widgetsSdkConfigured })
    }
}

extension GliaTests {
    struct ConfigurationFailureLogEntry: Equatable {
        let level: Glia.ConfigurationFailure.Level
        let message: String
    }

    struct OtelWarning: Equatable {
        let event: OtelLogEvents
        let message: String?
    }

    @MainActor
    func capturingOtelWarnings(_ body: () async -> Void) async -> [OtelWarning] {
        let originalOpenTelemetry = DependencyContainer.current.widgets.openTelemetry
        defer { DependencyContainer.current.widgets.openTelemetry = originalOpenTelemetry }
        var warnings: [OtelWarning] = []
        DependencyContainer.current.widgets.openTelemetry = .mock(
            configuration: .init(domain: ""),
            logger: .mock(w: { event, message, _ in
                warnings.append(.init(event: event, message: message))
            })
        )
        await body()
        return warnings
    }

    @MainActor
    func configureFailureLogs(
        for configurationError: Error
    ) async -> [ConfigurationFailureLogEntry] {
        var logs: [ConfigurationFailureLogEntry] = []
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
        logger.debugClosure = { _, _, _, _ in }
        logger.infoClosure = { _, _, _, _ in }
        logger.warningClosure = { message, _, _, _ in
            logs.append(.init(level: .warning, message: "\(message)"))
        }
        logger.errorClosure = { message, _, _, _ in
            logs.append(.init(level: .error, message: "\(message)"))
        }
        logger.prefixedClosure = { _ in logger }
        logger.configureLocalLogLevelClosure = { _ in }
        logger.configureRemoteLogLevelClosure = { _ in }
        environment.coreSdk.createLogger = { _ in logger }
        environment.conditionalCompilation.isDebug = { false }
        environment.coreSDKConfigurator.configureWithConfiguration = { _ in
            throw configurationError
        }
        let sdk = Glia(environment: environment)

        try? await sdk.configure(with: .mock(), theme: .mock())
        return logs
    }
}
