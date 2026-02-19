import SwiftUI
import GliaWidgets

struct VisitorInfoView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VisitorInfoViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Form {
                        basicInfoSection()
                        notesSection()
                        customAttributesSection()
                    }
                    .refreshable {
                        await viewModel.loadVisitorInfo()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .principal,
                    content: titleView
                )
                ToolbarItem(
                    placement: .topBarLeading,
                    content: cancelButton
                )
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: saveButton
                )
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
            .task {
                await viewModel.loadVisitorInfo()
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    func titleView() -> some View {
        TitleView(title: "Visitor Information")
    }

    @ViewBuilder
    func cancelButton() -> some View {
        Button("Cancel") {
            dismiss()
        }
        .accessibilityIdentifier("visitor_info_cancel_button")
    }

    @ViewBuilder
    func saveButton() -> some View {
        if viewModel.isSaving {
            ProgressView()
        } else {
            Button("Save") {
                Task {
                    await viewModel.saveVisitorInfo()
                    if viewModel.error == nil {
                        dismiss()
                    }
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .disabled(!viewModel.hasChanges)
            .accessibilityIdentifier("visitor_info_save_button")
        }
    }

    func basicInfoSection() -> some View {
        Section("Basic Information") {
            TextField("Name", text: $viewModel.name)
                .accessibilityIdentifier("visitor_info_name_field")
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .accessibilityIdentifier("visitor_info_email_field")
            TextField("Phone Number", text: $viewModel.phoneNumber)
                .keyboardType(.phonePad)
                .accessibilityIdentifier("visitor_info_phone_field")

            if #available(iOS 16.0, *) {
                LabeledContent("Visitor ID", value: viewModel.visitorId.isEmpty ? "N/A" : viewModel.visitorId)
                LabeledContent("External ID", value: viewModel.externalId.isEmpty ? "N/A" : viewModel.externalId)
            } else {
                HStack {
                    Text("Visitor ID")
                    Spacer()
                    Text(viewModel.visitorId.isEmpty ? "N/A" : viewModel.visitorId)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                HStack {
                    Text("External ID")
                    Spacer()
                    Text(viewModel.externalId.isEmpty ? "N/A" : viewModel.externalId)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
        }
    }

    func notesSection() -> some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Notes")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $viewModel.notesUpdateMethod) {
                        Text("Replace").tag(VisitorInfoUpdate.NoteUpdateMethod.replace)
                        Text("Append").tag(VisitorInfoUpdate.NoteUpdateMethod.append)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.secondary.opacity(0.3))
                    )
                    .accessibilityIdentifier("visitor_info_notes_field")
            }
        }
    }

    func customAttributesSection() -> some View {
        Section {
            HStack {
                Text("Custom Attributes")
                    .font(.headline)
                Spacer()
                Picker("", selection: $viewModel.attributesUpdateMethod) {
                    Text("Replace").tag(VisitorInfoUpdate.CustomAttributesUpdateMethod.replace)
                    Text("Merge").tag(VisitorInfoUpdate.CustomAttributesUpdateMethod.merge)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }

            ForEach(Array(viewModel.customAttributes.enumerated()), id: \.offset) { index, attribute in
                VStack(spacing: 8) {
                    TextField("Key", text: Binding(
                        get: { attribute.key },
                        set: { viewModel.updateCustomAttributeKey(at: index, key: $0) }
                    ))
                    .accessibilityIdentifier("visitor_info_custom_attribute_key_\(index)")

                    TextField("Value", text: Binding(
                        get: { attribute.value },
                        set: { viewModel.updateCustomAttributeValue(at: index, value: $0) }
                    ))
                    .accessibilityIdentifier("visitor_info_custom_attribute_value_\(index)")
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.removeCustomAttribute(at: index)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            Button {
                viewModel.addCustomAttribute()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Custom Attribute")
                }
            }
        }
    }
}
