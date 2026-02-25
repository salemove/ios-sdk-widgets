import SwiftUI
import GliaWidgets

struct ContentView: View {
    @StateObject private var viewModel: ViewModel
    @Binding var showSettings: Bool

    init(
        appState: AppState,
        showSettings: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(appState: appState))
        _showSettings = showSettings
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    engagementSection()
                    authenticationSection()
                    entryWidgetSection()
                    callVisualizerSection()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading,
                    content: configurationButton
                )
                ToolbarItem(
                    placement: .principal,
                    content: logoView
                )
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: settingsButton
                )
                ToolbarItem(
                    placement: .topBarTrailing,
                    content: actionsMenu
                )
            }
            .sheet(isPresented: $viewModel.showVisitorInfo) {
                VisitorInfoView()
                    .environmentObject(viewModel.appState)
            }
            .sheet(isPresented: $viewModel.showSensitiveData) {
                SensitiveDataView()
            }
            .alert(item: $viewModel.showError) { alertData in
                Alert(
                    title: Text(alertData.title),
                    message: Text(alertData.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

private extension ContentView {
    @ViewBuilder
    func logoView() -> some View {
        Image("glia")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .width(120)
            .height(40)
            .padding(.top, 8)
    }

    @ViewBuilder
    func configurationButton() -> some View {
        VStack(spacing: 16) {
            Button(action: {
                viewModel.configureSDK()
            }) {
                VStack {
                    switch viewModel.configurationState {
                    case .idle:
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .setColor(.gliaPrimary)
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gliaPrimary))
                            .scaleEffect(0.8)
                    case .configured:
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .heavy))
                            .setColor(.green)
                    case .error:
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .setColor(.red)
                    }
                }
                .disabled(viewModel.configurationState == .loading)
                .accessibilityIdentifier(
                    viewModel.configurationState == .loading
                    ? "main_configure_sdk_button_loading"
                    : "main_configure_sdk_button"
                )
            }
        }
    }

    @ViewBuilder
    func entryWidgetSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Entry Widget")

            VStack(spacing: 12) {
                ActionButton(
                    title: "Show Sheet",
                    icon: "rectangle.portrait.and.arrow.forward",
                    color: .gliaPrimary,
                    style: .compact
                ) {
                    viewModel.showEntryWidgetSheet()
                }
                .accessibilityIdentifier("main_entry_widget_sheet_button")

                EmbeddableWidgetContainer(
                    isExpanded: $viewModel.isEntryWidgetEmbedded,
                    title: "Embedded View",
                    color: .gliaPrimary,
                    action: {
                        viewModel.toggleEntryWidgetEmbed()
                    },
                    onContainerReady: { view in
                        viewModel.setEntryWidgetContainer(view)
                    },
                    expandedHeight: 300
                )
                .accessibilityIdentifier("main_entry_widget_embedded_button")
            }
        }
    }

    @ViewBuilder
    func callVisualizerSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Call Visualizer")

            VStack(spacing: 12) {
                ActionButton(
                    title: "Show Sheet",
                    icon: "rectangle.portrait.and.arrow.forward",
                    color: .gliaPrimary,
                    style: .compact
                ) {
                    viewModel.showVisitorCodeAlert()
                }
                .accessibilityIdentifier("main_present_visitor_code_as_alert_button")

                EmbeddableWidgetContainer(
                    isExpanded: $viewModel.isVisitorCodeEmbedded,
                    title: "Embedded View",
                    color: .gliaPrimary,
                    action: {
                        viewModel.toggleVisitorCodeEmbed()
                    },
                    onContainerReady: { view in
                        viewModel.setVisitorCodeContainer(view)
                    },
                    expandedHeight: 228
                )
                .accessibilityIdentifier("main_embed_visitor_code_view_button")
            }
        }
    }

    @ViewBuilder
    func engagementSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                EngagementButton(
                    title: "Chat",
                    icon: "message",
                    color: .blue
                ) {
                    viewModel.startEngagement { try viewModel.appState.startChat() }
                }
                .accessibilityIdentifier("main_chat_button")

                EngagementButton(
                    title: "Audio",
                    icon: "phone",
                    color: .green
                ) {
                    viewModel.startEngagement { try viewModel.appState.startAudioCall() }
                }
                .accessibilityIdentifier("main_audio_button")

                EngagementButton(
                    title: "Video",
                    icon: "video",
                    color: .gliaPrimary
                ) {
                    viewModel.startEngagement { try viewModel.appState.startVideoCall() }
                }
                .accessibilityIdentifier("main_video_button")

                EngagementButton(
                    title: "Secure",
                    icon: "lock.shield",
                    color: .orange
                ) {
                    viewModel.startEngagement { try viewModel.appState.startSecureMessaging() }
                }
                .accessibilityIdentifier("main_secure_messaging_button")
            }
            .maxWidth()
        }
    }

    @ViewBuilder
    func authenticationSection() -> some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Authentication")

            HStack(spacing: 12) {
                ActionButton(
                    title: viewModel.isAuthenticated ? "Deauthenticate" : "Authenticate",
                    icon: viewModel.isAuthenticated ? "key.slash.fill" : "key.fill",
                    color: .gliaPrimary,
                    style: .compact
                ) {
                    viewModel.handleAuthentication()
                }
                .accessibilityIdentifier("main_toggle_authenticate_button")

                ActionButton(
                    title: "Refresh Token",
                    icon: "arrow.clockwise",
                    color: .gliaPrimary,
                    style: .compact
                ) {
                    viewModel.showRefreshTokenAlert = true
                }
                .disabled(!viewModel.isAuthenticated)
                .accessibilityIdentifier("main_refresh_access_token_button")
            }
        }
        .alert("Add JWT authentication token", isPresented: $viewModel.showAuthenticationAlert) {
            TextField("JWT Token", text: $viewModel.jwtToken)
                .accessibilityIdentifier("authentication_id_token_textfield")
            TextField("Access Token (Optional)", text: $viewModel.accessToken)
                .accessibilityIdentifier("authentication_access_token_textfield")
            Button("Create Authentication") {
                viewModel.authenticateWithJWT()
            }
            .accessibilityIdentifier("create_authentication_alert_button")
            Button("Cancel", role: .cancel) {
                viewModel.jwtToken = ""
                viewModel.accessToken = ""
            }
            .accessibilityIdentifier("cancel_authentication_alert_button")
        }
        .alert("Refresh access token", isPresented: $viewModel.showRefreshTokenAlert) {
            TextField("JWT Token", text: $viewModel.jwtToken)
                .accessibilityIdentifier("authentication_refresh_token_textfield")
            TextField("Access Token (Optional)", text: $viewModel.accessToken)
                .accessibilityIdentifier("authentication_access_token_textfield")
            Button("Refresh") {
                viewModel.refreshAccessToken()
            }
            .accessibilityIdentifier("refresh_token_alert_refresh_button")
            Button("Cancel", role: .cancel) {
                viewModel.jwtToken = ""
                viewModel.accessToken = ""
            }
            .accessibilityIdentifier("cancel_authentication_alert_button")
        }
    }

    @ViewBuilder
    func settingsButton() -> some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gear")
                .font(.system(size: 16, weight: .bold))
                .setColor(.gliaPrimary)
        }
        .accessibilityIdentifier("main_settings_button")
    }

    @ViewBuilder
    func actionsMenu() -> some View {
        Menu {
            Button(
                action: viewModel.showVisitorInfoTapped,
                label: {
                    Label("Update Visitor Info", systemImage: "person.text.rectangle")
                })

            Button(
                action: viewModel.showSensitiveDataTapped,
                label: {
                    Label("Show Sensitive Data", systemImage: "eye.trianglebadge.exclamationmark")
                })

            Button(
                action: viewModel.resumeEngagement,
                label: {
                    Label("Resume Engagement", systemImage: "play.circle")
                }
            )

            Divider()

            Button(
                role: .destructive,
                action: viewModel.clearSession,
                label: {
                    Label("Clear Session", systemImage: "trash")
                }
            )
            Button(
                role: .destructive,
                action: viewModel.endEngagement,
                label: {
                    Label("End Engagement", systemImage: "xmark.circle")
                })
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 17, weight: .bold))
                .setColor(.gliaPrimary)
        }
        .accessibilityIdentifier("main_actions_menu")
    }
}
