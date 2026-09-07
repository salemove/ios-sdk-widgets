import Foundation
@_spi(GliaWidgets) internal import GliaCoreSDK

extension CoreSdkClient.Logger {
    init(_ logging: GliaCoreSDK.Logging) {
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
            guard let configurable = logging as? GliaCoreSDK.LogConfigurable else {
                throw LoggingError.localLogLevelConfigurationFailure
            }
            configurable.configureLocalLogLevel($0.coreLevel)
        }

        self.configureRemoteLogLevelClosure = {
            guard let configurable = logging as? GliaCoreSDK.LogConfigurable else {
                throw LoggingError.remoteLogLevelConfigurationFailure
            }
            configurable.configureRemoteLogLevel($0.coreLevel)
        }

        self.reportDeprecatedMethodClosure = {
            logging.reportDeprecatedMethod(context: $0, file: $1, function: $2, line: $3)
        }
    }
}
