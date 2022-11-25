import GliaWidgets
import SalemoveSDK

// Configure the Glia class
final class GliaConfiguration {
    let siteApiSecret = "gls_bMYHCO0jqQnEWYoW52cdmNfexJ5DTHKQYCfo"
    let siteApiId = "45fc1c28-27ab-4410-bcca-3805d9968f64"
    let environment: Environment = .beta
    let siteId = "1fcde86b-26ba-442f-99e1-68e9cff7ddb6"

    // Set the queue you want your visitors to connect to.
    // This queue is later on checked for being listed on site, being open,
    // and being available for visitors who want to engage via video.
    let queueId = "e309e779-4093-463b-a334-42332c39ec94"

    func composeConfiguration() -> Configuration {
        let configuration = Configuration(
            authorizationMethod: .siteApiKey(id: siteApiId, secret: siteApiSecret),
            environment: environment,
            site: siteId
        )
        return configuration
    }
}

/*

 GjeygPKDG3FrH7e8
 1fcde86b-26ba-442f-99e1-68e9cff7ddb6
 e309e779-4093-463b-a334-42332c39ec94

 Api key:
 45fc1c28-27ab-4410-bcca-3805d9968f64
 gls_bMYHCO0jqQnEWYoW52cdmNfexJ5DTHKQYCfo

 */
