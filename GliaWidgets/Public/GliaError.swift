/// An event providing error used to indicate something went wrong with the Widgets SDK.
public enum GliaError: Error {
    /// The engagement already exists.
    case engagementExists

    /// The engagement does not exist.
    case engagementNotExist

    /// The SDK is not configured.
    case sdkIsNotConfigured

    /// The Call Visualizer engagement exists.
    case callVisualizerEngagementExists

    /// Configuring during engagement is not allowed.
    case configuringDuringEngagementIsNotAllowed

    /// Clearing visitor session during engagement is not allowed.
    case clearingVisitorSessionDuringEngagementIsNotAllowed

    /// Starting engagement with no queue ids is not allowed.
    case startingEngagementWithNoQueueIdsIsNotAllowed

    /// The site API key credentials are invalid.
    case invalidSiteApiKeyCredentials

    /// The locale is invalid.
    case invalidLocale

    /// Internal error.
    case internalError
}
