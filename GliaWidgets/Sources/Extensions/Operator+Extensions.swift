@_spi(GliaWidgets) internal import GliaCoreSDK
extension CoreSdkClient.Operator {
    var firstName: String? {
        guard let first = name.split(separator: " ").first else { return nil }
        return String(first)
    }
}
