import Foundation

extension VisitorInfoUpdate {
    /// Specifies a method for updating the Visitor's notes.
    public enum NoteUpdateMethod: String {
        /// The notes for the Visitor will be overwritten by the  field `note` in the request.
        case replace
        /// A line break (`\n`) will be added and field `note` in the request will be appended to the existing
        /// Visitor’s notes.
        case append
    }
}

extension VisitorInfoUpdate.NoteUpdateMethod {
    func asCoreSdkNoteUpdateMethod() -> CoreSdkClient.CoreVisitorInfoUpdate.NoteUpdateMethod {
        switch self {
        case .replace:
            return .replace
        case .append:
            return .append
        }
    }
}
