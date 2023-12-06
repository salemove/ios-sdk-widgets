import Foundation
@_spi(GliaWidgets) import GliaCoreSDK

extension CoreSdkClient.Logger {
    init(_ logging: CoreSdkClient.Logging) {
        self.debugClosure = {
            logging.debug($0, file: $1, function: $2, line: $3)
        }
        self.infoClosure = { object, file, function, line in
            logging.info(object, file: file, function: function, line: line)
        }
        self.errorClosure = {
            logging.error($0, file: $1, function: $2, line: $3)
        }
        self.warningClosure = {
            logging.warning($0, file: $1, function: $2, line: $3)
        }
        self.localLoggerClosure = {
            logging.localLogger.map(Self.init)
        }
        self.remoteLoggerClosure = {
            logging.remoteLogger.map(Self.init)
        }
        self.oneTimeClosure = {
            Self(logging.oneTime)
        }
        self.prefixedClosure = { Self(logging.prefixed($0)) }
        self.configureLocalLogLevelClosure = {
            guard let logConfigurable = logging as? LogConfigurable else {
                throw LoggingError.localLogLevelConfigurationFailure
            }

            logConfigurable.configureLocalLogLevel($0)
        }

        self.configureRemoteLogLevelClosure = {
            guard let logConfigurable = logging as? LogConfigurable else {
                throw LoggingError.remoteLogLevelConfigurationFailure
            }
            logConfigurable.configureRemoteLogLevel($0)
        }

        self.reportDeprecatedMethodClosure = {
            logging.reportDeprecatedMethod(context: $0, file: $1, function: $2, line: $3)
        }
    }
}
