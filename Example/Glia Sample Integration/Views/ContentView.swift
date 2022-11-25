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
            .modifier(IsAvailable(presenter.isChatAvailable))

            Button("Audio Call") {
                presenter.startEngagement(.audioCall)
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(IsAvailable(presenter.isAudioAvailable))

            Button("Video Call") {
                presenter.startEngagement(.videoCall)
            }
            .buttonStyle(EngagementButtonStyle())
            .modifier(IsAvailable(presenter.isVideoAvailable))
        }
        .padding(.vertical, 48)
    }
}
