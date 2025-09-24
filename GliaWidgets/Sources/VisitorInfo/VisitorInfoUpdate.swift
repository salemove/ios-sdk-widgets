import Foundation

/// The information for updating Visitor
public struct VisitorInfoUpdate {
    /// Name of the Visitor.
    public var name: String?

    /// Email of the Visitor.
    public var email: String?

    /// Phone of the Visitor.
    public var phone: String?

    /// Notes associated with the Visitor.
    public var note: String?

    /// Method for updating the Visitor's note.
    public var noteUpdateMethod: NoteUpdateMethod?

    /// External ID to be used in third-party integrations.
    public var externalID: String?

    /// A dictionary with custom attributes.
    public var customAttributes: [String: String]?

    /// Method for updating custom attributes.
    public var customAttributesUpdateMethod: CustomAttributesUpdateMethod?

    /// Parameters:
    /// - name: The Visitor's name. The default value is `nil`.
    /// - email: The Visitor's email address. The default value is `nil`.
    /// - phone: The Visitor's phone number. The default value is `nil`.
    /// - note: The notes associated with the Visitor. The default value is `nil`.
    /// - noteUpdateMethod:  The method for updating the visitor's note. The default value is `nil`.
    /// - externalId: The Visitor's unique identifier in scope of the current Site. Valuable information about the
    /// current Visitor may often be available in CRMs and other systems external to Glia. This field allows
    /// matching the Visitor to their record in such CRMs and other external systems. For example, a Visitor can have an
    /// ID within Salesforce. By setting the 'external_id' to the current Visitor's Salesforce ID, they can easily be
    /// matched to their record within Salesforce. The default value is `nil`.
    /// - customAttributes: An object with custom key-value pairs to be assigned to the Visitor. The server treats all
    /// keys and values as strings and also returns them as strings. Nested key-value pairs are not supported. The default value is `nil`.
    /// - customAttributesUpdateMethod: The method for updating custom attributes. The default value is `nil`.
    ///
    public init(
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        note: String? = nil,
        noteUpdateMethod: NoteUpdateMethod? = nil,
        externalID: String? = nil,
        customAttributes: [String: String]? = nil,
        customAttributesUpdateMethod: CustomAttributesUpdateMethod? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.note = note
        self.noteUpdateMethod = noteUpdateMethod
        self.externalID = externalID
        self.customAttributes = customAttributes
        self.customAttributesUpdateMethod = customAttributesUpdateMethod
    }
}

extension VisitorInfoUpdate {
    func asCoreSdkVisitorInfoUpdate() -> CoreSdkClient.CoreVisitorInfoUpdate {
        .init(
            name: name,
            email: email,
            phone: phone,
            note: note,
            noteUpdateMethod: noteUpdateMethod?.asCoreSdkNoteUpdateMethod(),
            externalID: externalID,
            customAttributes: customAttributes,
            customAttributesUpdateMethod: customAttributesUpdateMethod?.asCoreSdkNoteUpdateMethod()
        )
    }
}
