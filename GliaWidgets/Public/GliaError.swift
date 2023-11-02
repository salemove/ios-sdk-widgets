/// An event providing error used to indicate something went wrong with the Widgets SDK
public enum GliaError: Error {
    case engagementExists
    case engagementNotExist
    case sdkIsNotConfigured
    case callVisualizerEngagementExists
    case configuringDuringEngagementIsNotAllowed
    case clearingVisitorSessionDuringEngagementIsNotAllowed
    case startingEngagementWithNoQueueIdsIsNotAllowed
    case invalidSiteApiKeyCredentials
    case invalidLocale
    case internalError
}
