import Foundation
import GliaCoreSDK

extension VisitorInfoUpdate {
    /// Specifies a method for updating custom attributes.
    public enum CustomAttributesUpdateMethod: String, Encodable {
        /// All custom attributes for the Visitor will be overwritten by the field.
        case replace
        /// Only custom attributes present in the request will be added or updated. In case of merge it is
        /// possible to remove a custom attribute by setting its value to `nil`.
        case merge
    }
}

extension VisitorInfoUpdate.CustomAttributesUpdateMethod {
    func asCoreSdkNoteUpdateMethod() -> GliaCoreSDK.VisitorInfoUpdate.CustomAttributesUpdateMethod {
        switch self {
        case .replace:
            return .replace
        case .merge:
            return .merge
        }
    }
}
