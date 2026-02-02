import SwiftUI
import GliaWidgets

@MainActor
final class VisitorInfoViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var notes: String = ""
    @Published var externalId: String = ""
    @Published var visitorId: String = ""
    @Published var customAttributes: [CustomAttribute] = []
    @Published var notesUpdateMethod: VisitorInfoUpdate.NoteUpdateMethod = .replace
    @Published var attributesUpdateMethod: VisitorInfoUpdate.CustomAttributesUpdateMethod = .merge

    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: String?
    @Published var hasChanges = false

    private var originalInfo: VisitorInfo?

    func loadVisitorInfo() async {
        isLoading = true
        error = nil

        Glia.sharedInstance.getVisitorInfo { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isLoading = false
                switch result {
                case .success(let info):
                    self?.populateFields(from: info)
                    self?.originalInfo = info
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func saveVisitorInfo() async {
        isSaving = true
        error = nil

        let info = VisitorInfoUpdate(
            name: name.isEmpty ? nil : name,
            email: email.isEmpty ? nil : email,
            phone: phoneNumber.isEmpty ? nil : phoneNumber,
            note: notes.isEmpty ? nil : notes,
            noteUpdateMethod: notesUpdateMethod,
            customAttributes: customAttributes.isEmpty ? nil : Dictionary(
                customAttributes.map { ($0.key, $0.value) },
                uniquingKeysWith: { first, _ in first }
            ),
            customAttributesUpdateMethod: attributesUpdateMethod
        )

        Glia.sharedInstance.updateVisitorInfo(info) { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isSaving = false
                switch result {
                case .success:
                    self?.hasChanges = false
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func addCustomAttribute() {
        customAttributes.append(CustomAttribute(key: "", value: ""))
        hasChanges = true
    }

    func removeCustomAttribute(at index: Int) {
        customAttributes.remove(at: index)
        hasChanges = true
    }

    func updateCustomAttributeKey(at index: Int, key: String) {
        guard index < customAttributes.count else { return }
        customAttributes[index].key = key
        hasChanges = true
    }

    func updateCustomAttributeValue(at index: Int, value: String) {
        guard index < customAttributes.count else { return }
        customAttributes[index].value = value
        hasChanges = true
    }

    private func populateFields(from info: VisitorInfo) {
        name = info.name ?? ""
        email = info.email ?? ""
        phoneNumber = info.phone ?? ""
        notes = info.note ?? ""
        externalId = info.externalId ?? ""
        visitorId = info.id ?? ""

        if let attributes = info.customAttributes {
            customAttributes = attributes.map { CustomAttribute(key: $0.key, value: $0.value) }
        }

        hasChanges = false
    }
}

