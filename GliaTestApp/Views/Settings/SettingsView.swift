import SwiftUI
import GliaWidgets

struct SettingsView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: ViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: AppState()))
    }

    var body: some View {
        NavigationView {
            Form {
                environmentSection()
                configurationSection()
                authenticationSection()
                featuresSection()
                themeColorsSection()
                themeFontsSection()
                versionSection()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading,
                    content: cancelButton
                )
                ToolbarItem(
                    placement: .principal,
                    content: titleView
                )
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: doneButton
                )
            }
            .onAppear {
                viewModel.appState = appState
                viewModel.loadCurrentSettings()
            }
            .onReceive(appState.$configuration) { _ in
                viewModel.loadCurrentSettings()
            }
            .onReceive(appState.$queueId) { _ in
                viewModel.loadCurrentSettings()
            }
            .onChange(of: viewModel.authorizationMethodSelection) { selection in
                viewModel.didChangeAuthorizationMethodSelection(to: selection)
            }
            .sheet(isPresented: $viewModel.showQueuePicker) {
                QueuePickerView(
                    queues: viewModel.availableQueues,
                    isLoading: viewModel.isLoadingQueues,
                    error: viewModel.queueError,
                    selectedQueueId: $viewModel.queueId
                )
            }
            .alert(item: $viewModel.showError) { alertData in
                Alert(
                    title: Text(alertData.title),
                    message: Text(alertData.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}

private extension SettingsView {
    @ViewBuilder
    func titleView() -> some View {
        TitleView(title: "Settings")
    }

    @ViewBuilder
    func cancelButton() -> some View {
        Button("Cancel") {
            dismiss()
        }
    }

    @ViewBuilder
    func doneButton() -> some View {
        Button("Done") {
            viewModel.saveSettings()
            dismiss()
        }
        .font(.system(size: 17, weight: .semibold))
        .accessibilityIdentifier("screen_settings_barButtonItem_done")
    }

    @ViewBuilder
    func versionSection() -> some View {
        Section("SDK Versions") {
            if #available(iOS 16.0, *) {
                LabeledContent("GliaWidgets", value: viewModel.gliaWidgetsVersion)
                LabeledContent("GliaCoreSDK", value: viewModel.gliaCoreSDKVersion)
                LabeledContent("GliaOpenTelemetry", value: viewModel.gliaOpenTelemetryVersion)
            } else {
                HStack {
                    Text("GliaWidgets")
                    Spacer()
                    Text(viewModel.gliaWidgetsVersion)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("GliaCoreSDK")
                    Spacer()
                    Text(viewModel.gliaCoreSDKVersion)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("GliaOpenTelemetry")
                    Spacer()
                    Text(viewModel.gliaOpenTelemetryVersion)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    func environmentSection() -> some View {
        Section("Environment") {
            Picker("Environment", selection: $viewModel.environmentSelection) {
                Text("Beta").tag(EnvironmentSelection.beta)
                Text("US").tag(EnvironmentSelection.us)
                Text("EU").tag(EnvironmentSelection.eu)
                Text("Custom").tag(EnvironmentSelection.custom)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("settings_environment_picker")
            if viewModel.environmentSelection == .custom {
                TextField("Custom URL", text: $viewModel.customEnvironmentUrl)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .accessibilityIdentifier("settings_custom_environment_url_textfield")
            }
        }
    }

    @ViewBuilder
    func configurationSection() -> some View {
        Section("Glia Configuration") {
            TextField("Site", text: $viewModel.site)
                .autocapitalization(.none)
                .accessibilityIdentifier("settings_siteId_textfield")

            TextField("Company Name", text: $viewModel.companyName)
                .accessibilityIdentifier("settings_companyName_textfield")

            Picker("Auth Method", selection: $viewModel.authorizationMethodSelection) {
                Text("Site API Key").tag(SettingsView.AuthorizationMethodSelection.siteApiKey)
                Text("User API Key").tag(SettingsView.AuthorizationMethodSelection.userApiKey)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("settings_authMethod_segmentedControl")

            TextField(
                viewModel.selectedApiKeyIdentifierTitle,
                text: Binding(
                    get: { viewModel.selectedApiKeyId },
                    set: { viewModel.selectedApiKeyId = $0 }
                )
            )
                .autocapitalization(.none)
                .accessibilityIdentifier("settings_apiKeyId_textfield")

            TextField(
                viewModel.selectedApiKeySecretTitle,
                text: Binding(
                    get: { viewModel.selectedApiKeySecret },
                    set: { viewModel.selectedApiKeySecret = $0 }
                )
            )
                .accessibilityIdentifier("settings_apiKeySecret_textfield")

            Toggle(
                "Use Default Queue",
                isOn: $viewModel.useDefaultQueue
            )
            .accessibilityIdentifier("settings_use_default_queue_switch")

            if !viewModel.useDefaultQueue {
                HStack {
                    TextField("Queue ID", text: $viewModel.queueId)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("settings_queueId_textfield")

                    Button {
                        viewModel.loadQueues()
                    } label: {
                        Image(systemName: "list.bullet")
                            .imageScale(.large)
                    }
                }
            }

            TextField("Visitor Context Asset ID", text: $viewModel.visitorContextAssetId)
                .autocapitalization(.none)
                .accessibilityIdentifier("settings_visitor_context_assetId_textfield")

            TextField("Manual Locale Override", text: $viewModel.manualLocaleOverride)
                .autocapitalization(.none)
                .accessibilityIdentifier("settings_manual_locale_override_textfield")

            Toggle(
                "Auto-configure Before Engagement",
                isOn: $viewModel.autoConfigureEnabled
            )
            .accessibilityIdentifier("settings_auto_configure_switch")
        }
    }

    @ViewBuilder
    func authenticationSection() -> some View {
        Section("Authentication") {
            Picker("Behavior During Engagement", selection: $viewModel.authenticationBehavior) {
                Text("Forbidden")
                    .tag(Glia.Authentication.Behavior.forbiddenDuringEngagement)
                Text("Allowed")
                    .tag(Glia.Authentication.Behavior.allowedDuringEngagement)
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings_authentication_behavior_picker")
            Toggle(
                "Suppress Push Permission",
                isOn: $viewModel.suppressPushPermission
            )
            .accessibilityIdentifier("settings_suppress_push_permission_switch")
            Toggle(
                "Stop Push Notifications on Logout",
                isOn: $viewModel.stopPushOnDeauthenticate
            )
            .accessibilityIdentifier("settings_stop_push_on_deauth_switch")
        }
    }

    func featuresSection() -> some View {
        Section("Features") {
            Toggle(
                "Present Bubble Overlay During Engagement",
                isOn: $viewModel.bubbleFeatureEnabled
            )

            Toggle(
                "Use Remote Configuration",
                isOn: $viewModel.useRemoteConfiguration
            )
            .accessibilityIdentifier("settings_use_remote_config_switch")

            if viewModel.useRemoteConfiguration {
                Picker("Configuration", selection: $viewModel.selectedRemoteConfig) {
                    ForEach(viewModel.availableRemoteConfigs, id: \.self) { config in
                        Text(config).tag(config)
                    }
                }
                .accessibilityIdentifier("settings_remote_config_picker")

                if viewModel.selectedRemoteConfig == "None" {
                    Text("No configuration selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Selected: \(viewModel.selectedRemoteConfig)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    func themeColorsSection() -> some View {
        Section("Theme Colors") {
            ColorPickerRow(title: "Primary", color: $viewModel.themeColors.primary)
            ColorPickerRow(title: "Secondary", color: $viewModel.themeColors.secondary)
            ColorPickerRow(title: "Base Normal", color: $viewModel.themeColors.baseNormal)
            ColorPickerRow(title: "Base Light", color: $viewModel.themeColors.baseLight)
            ColorPickerRow(title: "Base Dark", color: $viewModel.themeColors.baseDark)
            ColorPickerRow(title: "Base Shade", color: $viewModel.themeColors.baseShade)
            ColorPickerRow(title: "System Negative", color: $viewModel.themeColors.systemNegative)
        }
    }

    func themeFontsSection() -> some View {
        Section("Theme Fonts") {
            NavigationLink("Header 1") {
                FontPickerView(
                    title: "Header 1",
                    selectedFont: $viewModel.themeFonts.header1
                )
            }
            NavigationLink("Header 2") {
                FontPickerView(
                    title: "Header 2",
                    selectedFont: $viewModel.themeFonts.header2
                )
            }
            NavigationLink("Header 3") {
                FontPickerView(
                    title: "Header 3",
                    selectedFont: $viewModel.themeFonts.header3
                )
            }
            NavigationLink("Body Text") {
                FontPickerView(
                    title: "Body Text",
                    selectedFont: $viewModel.themeFonts.bodyText
                )
            }
            NavigationLink("Subtitle") {
                FontPickerView(
                    title: "Subtitle",
                    selectedFont: $viewModel.themeFonts.subtitle
                )
            }
            NavigationLink("Medium Subtitle 1") {
                FontPickerView(
                    title: "Medium Subtitle 1",
                    selectedFont: $viewModel.themeFonts.mediumSubtitle1
                )
            }
            NavigationLink("Medium Subtitle 2") {
                FontPickerView(
                    title: "Medium Subtitle 2",
                    selectedFont: $viewModel.themeFonts.mediumSubtitle2
                )
            }
            NavigationLink("Caption") {
                FontPickerView(
                    title: "Caption",
                    selectedFont: $viewModel.themeFonts.caption
                )
            }
            NavigationLink("Button Label") {
                FontPickerView(
                    title: "Button Label",
                    selectedFont: $viewModel.themeFonts.buttonLabel
                )
            }
        }
    }
}

private extension SettingsView {
    struct ColorPickerRow: View {
        let title: String
        @Binding var color: Color

        var body: some View {
            HStack {
                Text(title)
                Spacer()
                ColorPicker("", selection: $color)
                    .labelsHidden()
            }
        }
    }
}
