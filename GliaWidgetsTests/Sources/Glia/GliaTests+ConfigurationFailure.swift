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
}

extension GliaTests {
    struct ConfigurationFailureLogEntry: Equatable {
        let level: Glia.ConfigurationFailure.Level
        let message: String
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
