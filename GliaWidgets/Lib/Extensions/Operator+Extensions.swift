import SalemoveSDK

extension Operator {
    var firstName: String? {
        guard let first = name.split(separator: " ").first else { return nil }
        return String(first)
    }
}
