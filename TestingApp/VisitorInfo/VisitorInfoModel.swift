import Combine
import GliaWidgets
import GliaCoreSDK

final class VisitorInfoModel {
    typealias Props = VisitorInfoViewController.Props
    typealias Section = Props.Section
    typealias InfoField = Props.InfoField
    typealias KeyValuePair = Props.KeyValuePair
    typealias CustomAttributesUpdateMethod = Props.InfoField.CustomAttributesUpdateMethod
    typealias NotesUpdateMethod = InfoField.NotesUpdateMethod
    typealias HeaderViewProps = HeaderView.Props
    typealias HeaderButton = HeaderViewProps.ActionButton
    typealias Segment = HeaderView.Props.Segment
    typealias Delegate = (DelegateEvent) -> Void
    typealias UpdateButton = Props.UpdateButton
    typealias CancelButton = Props.CancelButton

    // Stores visitor fields to be sent for update.
    var visitorInfoUpdate = VisitorInfoUpdate() {
        didSet {
            requestPropsRendered()
        }
    }

    var previousVisitorInfoUpdate: VisitorInfoUpdate = VisitorInfoUpdate() {
        didSet {
            requestPropsRendered()
        }
    }

    // Keeps track of *fetch* visitor info request state.
    var fetchInfoRequestState: RequestState<GliaCore.VisitorInfo>? {
        didSet {
            requestPropsRendered()
        }
    }
    // Keeps track of *update* visitor info request state.
    var updateInfoRequestState: RequestState<Bool>? {
        didSet {
            requestPropsRendered()
        }
    }
    // Keeps attributes ordered, to
    // have consistent text field order,
    // since `customAttributes` is represented
    // by `Dictionary` which does not have ordered keys.
    var attributeIDs: [UUID] = []
    // Keeps attributes identifiable,
    // and lookup-able by identifier.
    var attributes: [UUID: (id: UUID, key: String, value: String)] = [:] {
        didSet {
            var rawCustomAttributes: [String: String] = self.visitorInfoUpdate.customAttributes ?? [:]

            // Remove outdated key-values.
            for (_, attribute) in oldValue {
                rawCustomAttributes[attribute.key] = nil
            }

            // Set relevant key-values.
            for (_, attribute) in attributes {
                rawCustomAttributes[attribute.key] = attribute.value
            }

            self.visitorInfoUpdate.customAttributes = rawCustomAttributes
        }
    }

    var noteUpdateMethod: VisitorInfoUpdate.NoteUpdateMethod = .replace {
        didSet {
            self.visitorInfoUpdate.noteUpdateMethod = noteUpdateMethod
        }
    }

    var customAttributesUpdateMethod: VisitorInfoUpdate.CustomAttributesUpdateMethod = .replace {
        didSet {
            self.visitorInfoUpdate.customAttributesUpdateMethod = customAttributesUpdateMethod
        }
    }

    var delegate: Delegate?

    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func loadVisitorInfo() {
        self.fetchInfoRequestState = .inFlight
        environment.fetchVisitorInfo { [weak self] result in
            guard let self else { return }
            // Attributes needs to be ordered in some way,
            // that is why we need to keep their IDs in order.
            // We remove information about order every time
            // visitor info is fetched.
            self.attributeIDs.removeAll(keepingCapacity: true)
            self.attributes.removeAll(keepingCapacity: true)

            self.fetchInfoRequestState = .result(result)
            switch result {
            case let .success(fetchedVisitorInfo):
                let visitorInfoUpdate = VisitorInfoUpdate(
                    name: fetchedVisitorInfo.name ?? "",
                    email: fetchedVisitorInfo.email ?? "",
                    phone: fetchedVisitorInfo.phone ?? "",
                    note: fetchedVisitorInfo.note ?? "",
                    // Update method for note is not present in visitor info,
                    // so we use locally stored one.
                    noteUpdateMethod: self.noteUpdateMethod,
                    // External id is not available in fetched info,
                    // so we do not show it in UI.
                    externalID: nil,
                    customAttributes: fetchedVisitorInfo.customAttributes,
                    // Update method for custom attributes is not present in visitor info,
                    // so we use locally stored one.
                    customAttributesUpdateMethod: self.customAttributesUpdateMethod
                )

                // Sort custom attribute keys to have them oredered.
                let keys = (fetchedVisitorInfo.customAttributes ?? [:]).keys.sorted(by: <)
                for key in keys {
                    guard let value = fetchedVisitorInfo.customAttributes?[key] else { continue }
                    let id = self.environment.uuid()
                    self.attributeIDs.append(id)
                    self.attributes[id] = (id: id, key: key, value: value)
                }

                self.previousVisitorInfoUpdate = visitorInfoUpdate
                self.visitorInfoUpdate = visitorInfoUpdate
            case let .failure(error):
                print("Error", error)
            }
        }
    }

    func updateVisitorInfo() {
        self.updateInfoRequestState = .inFlight
        self.environment.updateVisitorInfo(self.visitorInfoUpdate) { [weak self] result in
            guard let self else { return }
            self.updateInfoRequestState = nil
            switch result {
            case .success:
                self.previousVisitorInfoUpdate = self.visitorInfoUpdate
            case let .failure(error):
                print(error)
            }
        }
    }

    func props() -> Props {
        let nameField = InfoField.name(
            label: "Name:",
            value: self.visitorInfoUpdate.name ?? "",
            update: .init { [weak self] in self?.visitorInfoUpdate.name = $0 }
        )

        let emailField = InfoField.email(
            label: "Email:",
            value: self.visitorInfoUpdate.email ?? "",
            update: .init { [weak self] in
                self?.visitorInfoUpdate.email = $0
            }
        )

        let phoneField = InfoField.phoneNumber(
            label: "Phone:",
            value: self.visitorInfoUpdate.phone ?? "",
            update: .init { [weak self] in self?.visitorInfoUpdate.phone = $0 }
        )

        let fieldsHeader = HeaderViewProps(headerTitle: "Fields")

        let fieldsSection = Section.fields(
            title: fieldsHeader,
            fields: [
                nameField,
                emailField,
                phoneField
            ]
        )

        let noteField = InfoField.notes(
            placeholder: "Enter notes",
            text: self.visitorInfoUpdate.note ?? "",
            update: .init { [weak self] text in
                self?.visitorInfoUpdate.note = text
            }
        )

        let appendNoteSegment = Segment(
            title: NotesUpdateMethod.append.label(),
            select: Cmd { [weak self] in
                self?.noteUpdateMethod = .append
            }
        )
        let replaceNoteSegment = Segment(
            title: NotesUpdateMethod.replace.label(),
            select: Cmd { [weak self] in
                self?.noteUpdateMethod = .replace
            }
        )

        let noteSelectedSegment: Segment

        switch self.noteUpdateMethod {
        case .append:
            noteSelectedSegment = appendNoteSegment
        case .replace:
            noteSelectedSegment = replaceNoteSegment
        @unknown default:
            noteSelectedSegment = replaceNoteSegment
        }

        let noteHeader = HeaderViewProps(
            headerTitle: "Notes",
            segments: [
                appendNoteSegment,
                replaceNoteSegment
            ],
            selectedSegment: noteSelectedSegment,
            segmentAccessibilityIdentifierPrefix: "visitor_info_notes_method_"
        )

        let noteSection = Section.notes(
            title: noteHeader,
            notes: noteField
        )

        let mergeAttributesSegment = Segment(
            title: CustomAttributesUpdateMethod.merge.label(),
            select: Cmd { [weak self] in
                self?.customAttributesUpdateMethod = .merge
            }
        )
        let replaceAttributesSegment = Segment(
            title: CustomAttributesUpdateMethod.replace.label(),
            select: Cmd { [weak self] in
                self?.customAttributesUpdateMethod = .replace
            }
        )

        let attributesSelectedSegment: Segment

        switch self.customAttributesUpdateMethod {
        case .replace:
            attributesSelectedSegment = replaceAttributesSegment
        case .merge:
            attributesSelectedSegment = mergeAttributesSegment
        @unknown default:
            attributesSelectedSegment = replaceAttributesSegment
        }

        let addAttributeButton = HeaderButton(
            title: "+",
            tap: Cmd { [weak self] in
                guard let self else { return }
                
                let keys: Set = Set(self.attributes.values.map(\.key))

                var nextAttributeKeyCounter = 0
                var key: String { "key\(nextAttributeKeyCounter)" }

                while keys.contains(key) {
                    nextAttributeKeyCounter += 1
                }

                let id = self.environment.uuid()

                let pair = KeyValuePair(
                    key: key,
                    keyUpdate: Command { [weak self] key in
                        self?.attributes[id]?.key = key
                    },
                    value: "",
                    valueUpdate: Command { [weak self] value in
                        self?.attributes[id]?.value = value
                    },
                    remove: Cmd {
                        self.attributes.removeValue(forKey: id)
                        self.attributeIDs.removeAll(where: { $0 == id })
                    },
                    keyFieldAccIdentifier: "visitor_info_custom_attribute_key_input_\(self.attributeIDs.count)",
                    valueFieldAccIdentifier: "visitor_info_custom_attribute_value_input_\(self.attributeIDs.count)"
                )

                self.attributeIDs.append(id)
                self.attributes[id] = (id: id, key: pair.key, value: pair.value)
            },
            accIdentifier: "visitor_info_add_custom_attribute_button"
        )
        let attributesHeader = HeaderViewProps(
            title: "Custom attributes",
            segments: [
                mergeAttributesSegment,
                replaceAttributesSegment
            ],
            selectedSegment: attributesSelectedSegment,
            actionButton: addAttributeButton,
            segmentAccessibilityIdentifierPrefix: "visitor_info_custom_attribute_method_"
        )
        let customAttributesSection = Section.customAttributes(
            title: attributesHeader,
            attributes: zip(self.attributeIDs, 0...).compactMap { id, idx in
                guard let attribute = self.attributes[id] else {
                    return nil
                }

                let remove = Cmd { [weak self] in
                    self?.attributeIDs.removeAll { $0 == id }
                    self?.attributes[id] = nil
                    self?.visitorInfoUpdate.customAttributes?[attribute.key] = nil
                }

                let keyUpdate = Command<String> { [weak self] key in
                    var attribute = attribute
                    attribute.key = key
                    self?.attributes[attribute.id] = attribute
                }

                let valueUpdate = Command<String> { [weak self] value in
                    var attribute = attribute
                    attribute.value = value
                    self?.attributes[attribute.id] = attribute
                }

                return .customAttributes(
                    KeyValuePair(
                        key: attribute.key,
                        keyUpdate: keyUpdate,
                        value: attribute.value,
                        valueUpdate: valueUpdate,
                        remove: remove,
                        keyFieldAccIdentifier: "visitor_info_custom_attribute_key_input_\(idx)",
                        valueFieldAccIdentifier: "visitor_info_custom_attribute_value_input_\(idx)"
                    )
                )
            }
        )

        let pulledToRefresh = Cmd { [weak self] in
            self?.loadVisitorInfo()
        }

        let cancelTap = Cmd { [weak self] in
            self?.delegate?(.cancel)
        }

        let updateTap = Cmd { [weak self] in
            self?.updateVisitorInfo()
        }

        let hasChanges: Bool = !Self.diffBetweenVisitorInfoUpdates(
            updateA: self.visitorInfoUpdate,
            updateB: self.previousVisitorInfoUpdate
        ).isEmpty

        let updateButton: UpdateButton
        switch self.updateInfoRequestState {
        case .none, .result:
            updateButton = .normal(
                updateTap,
                isEnabled: hasChanges,
                accIdentifier: "visitor_info_save_button"
            )
        case .inFlight:
            updateButton = .loading
        }

        let cancelButton = CancelButton(
            tap: cancelTap,
            accIdentifier: "visitor_info_cancel_button"
        )

        let props = Props(
            title: "Visitor Info",
            sections: [
                fieldsSection,
                noteSection,
                customAttributesSection
            ],
            pulledToRefresh: pulledToRefresh,
            showsRefreshing: self.fetchInfoRequestState == .inFlight,
            cancelButton: cancelButton,
            updateButton: updateButton
        )

        return props
    }

    func requestPropsRendered() {
        self.delegate?(.renderProps(self.props()))
    }

    fileprivate enum DiffField {
        case name, email, phone, note, noteUpdateMethod, customAttributesUpdateMethod
        case customAttributes(lhs: [String: String], rhs: [String: String])
    }

    fileprivate static func diffBetweenVisitorInfoUpdates(
        updateA: VisitorInfoUpdate,
        updateB: VisitorInfoUpdate
    ) -> [DiffField] {
        var fields: [DiffField] = []

        if updateA.name ?? "" != updateB.name ?? "" {
            fields.append(.name)
        }

        if updateA.email ?? "" != updateB.email ?? "" {
            fields.append(.email)
        }

        if updateA.phone ?? "" != updateB.phone ?? "" {
            fields.append(.phone)
        }

        if updateA.note ?? "" != updateB.note ?? "" {
            fields.append(.note)
        }

        if updateA.customAttributes ?? [:] != updateB.customAttributes ?? [:] {
            fields.append(
                .customAttributes(
                    lhs: updateA.customAttributes ?? [:],
                    rhs: updateB.customAttributes ?? [:]
                )
            )
        }

        if updateA.customAttributesUpdateMethod != updateB.customAttributesUpdateMethod {
            fields.append(.customAttributesUpdateMethod)
        }

        if updateA.noteUpdateMethod != updateB.noteUpdateMethod {
            fields.append(.noteUpdateMethod)
        }

        return fields
    }
}

extension VisitorInfoModel {
    struct Environment {
        let fetchVisitorInfo: (@escaping (Result<GliaCore.VisitorInfo, Error>) -> Void) -> Void
        let updateVisitorInfo: (VisitorInfoUpdate, @escaping (Result<Bool, Error>) -> Void) -> Void
        let uuid: () -> UUID
    }
}

extension VisitorInfoModel {
    enum RequestState<Value: Equatable> {
        case inFlight
        case result(Result<Value, Error>)
    }
}

extension VisitorInfoModel.RequestState: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case(.inFlight, .inFlight):
            return true
        case (.result, .inFlight), (.inFlight, .result):
            return false
        case let (.result(.success(lhsInfo)), .result(.success(rhsInfo))):
            return lhsInfo == rhsInfo
        case let (.result(.failure(lhsError)), .result(.failure(rhsError))):
            return lhsError as NSError == rhsError as NSError
        case (.result(.failure), .result(.success)), (.result(.success), .result(.failure)):
            return false
        }
    }
}

extension VisitorInfoModel {
    enum DelegateEvent {
        case cancel
        case renderProps(VisitorInfoViewController.Props)
    }
}
