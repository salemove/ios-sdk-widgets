import XCTest

@testable import GliaWidgets

extension GliaTests {
    func test_configureLogsWarningWhenSiteSettingsRetrievalFails() throws {
        let logs = try configureFailure(for: CoreSdkClient.ConfigurationProcessError.siteSettingsRetrieval).logs

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: siteSettingsRetrieval")])
    }

    func test_configureLogsWarningWhenLocaleRetrievalFails() throws {
        let logs = try configureFailure(for: CoreSdkClient.ConfigurationProcessError.localeRetrieval).logs

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: localeRetrieval")])
    }

    func test_configureLogsWarningWhenLocaleIsEmpty() throws {
        let logs = try configureFailure(for: CoreSdkClient.ConfigurationProcessError.emptyLocale).logs

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: emptyLocale")])
    }

    func test_configureLogsWarningWhenNetworkErrorOccurs() throws {
        let logs = try configureFailure(for: CoreSdkClient.GeneralError.networkError).logs

        XCTAssertEqual(logs, [.init(level: .warning, message: "Glia Widgets SDK initialization failed: networkError")])
    }

    func test_configureLogsErrorWhenInternalErrorOccurs() throws {
        let logs = try configureFailure(for: CoreSdkClient.GeneralError.internalError).logs

        XCTAssertEqual(logs, [.init(level: .error, message: "Glia Widgets SDK initialization failed: internalError")])
    }

    func test_configureLogsErrorWhenConfigurationIsInvalid() throws {
        let logs = try configureFailure(for: CoreSdkClient.ConfigurationError.invalidConfiguration).logs

        XCTAssertEqual(logs, [.init(level: .error, message: "Glia Widgets SDK initialization failed: invalidConfiguration")])
    }

    func test_configureLogsErrorWithTypeNameForUnknownError() throws {
        struct SecretBearingError: Error {
            let secret = "s3cr3t"
        }

        let logs = try configureFailure(for: SecretBearingError()).logs

        XCTAssertEqual(logs, [.init(level: .error, message: "Glia Widgets SDK initialization failed: SecretBearingError")])
        XCTAssertFalse(logs.contains { $0.message.contains("s3cr3t") })
    }
}

extension GliaTests {
    struct ConfigurationFailureLogEntry: Equatable {
        let level: Glia.ConfigurationFailure.Level
        let message: String
    }

    func configureFailure(
        for configurationError: Error
    ) throws -> (error: Error?, logs: [ConfigurationFailureLogEntry]) {
        var logs: [ConfigurationFailureLogEntry] = []
        var environment = Glia.Environment.failing
        var logger = CoreSdkClient.Logger.failing
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
        environment.coreSDKConfigurator.configureWithConfiguration = { _, completion in
            completion(.failure(configurationError))
        }
        let sdk = Glia(environment: environment)

        var receivedError: Error?
        try sdk.configure(
            with: .mock(),
            theme: .mock()
        ) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
        }
        return (receivedError, logs)
    }
}
