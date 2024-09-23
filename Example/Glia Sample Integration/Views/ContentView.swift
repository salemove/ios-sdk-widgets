import SwiftUI

struct ContentView: View {
    @ObservedObject var presenter = ContentViewPresenter()

    var body: some View {
        VStack(spacing: 16){
            Image("Glia")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(80)

            Spacer()

            Button("Chat") {
                presenter.startEngagement(.chat)
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(IsAvailable(presenter.isChatAvailable && presenter.isSDKLoaded))

            Button("Audio Call") {
                presenter.startEngagement(.audioCall)
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(IsAvailable(presenter.isAudioAvailable && presenter.isSDKLoaded))

            Button("Video Call") {
                presenter.startEngagement(.videoCall)
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(IsAvailable(presenter.isVideoAvailable && presenter.isSDKLoaded))
            
            Button("Call Visualizer") {
                presenter.showVisitorCode()
            }
            .modifier(IsAvailable(presenter.isSDKLoaded))
            .buttonStyle(EngagementButtonStyle())
            
            Button("Secure Conversation") {
                presenter.startEngagement(.messaging(.welcome))
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(
                IsAvailable(presenter.isAsyncMessagesAvailable && presenter.isAuthenticated && presenter.isSDKLoaded)
            )
            
            Button(presenter.isAuthenticated ? "Deauthenticate" : "Authenticate") {
                presenter.isAuthenticated ? presenter.deauthenticate() : presenter.authenticate()
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(IsAvailable(presenter.isAsyncMessagesAvailable && presenter.isSDKLoaded))
        }
        .padding(.vertical, 48)
    }
}
