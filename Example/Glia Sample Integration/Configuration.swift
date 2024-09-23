import GliaWidgets

// Configure the Glia class
final class GliaConfiguration {
    let siteApiSecret = ""
    let siteApiId = ""
    let environment: Environment = .beta
    let siteId = ""

    // Set the queue you want your visitors to connect to.
    // This queue is later on checked for being listed on site, being open,
    // and being available for visitors who want to engage via video.
    let queueId = ""
    
    // Set DirectID token to authenticate user.
    // With authenticated user you will be able to start Secure Conversation
    // and operators will get user data from JWT token on their side
    let directIdToken = ""

    func composeConfiguration() -> Configuration {
        let configuration = Configuration(
            authorizationMethod: .siteApiKey(id: siteApiId, secret: siteApiSecret),
            environment: environment,
            site: siteId
        )
        return configuration
    }
}
