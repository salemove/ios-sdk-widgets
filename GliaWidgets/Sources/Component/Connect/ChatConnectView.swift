import SwiftUI

struct ChatConnectView: View {
    @SwiftUI.Environment(\.verticalSizeClass) private var verticalSizeClass
    @SwiftUI.State private var connectingStartDate: Date?
    @ObservedObject var model: ChatConnectViewHost.Model

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var topPadding: CGFloat {
        let base: CGFloat
        switch model.state {
        case .connected, .onHold: base = 14
        case .initial, .queue, .connecting, .transferring: base = 6
        }
        return isLandscape ? base / 2 : base
    }

    private var contentSpacing: CGFloat {
        let base: CGFloat
        switch model.state {
        case .connected, .onHold:
            base = 16
        case .initial, .queue, .connecting, .transferring:
            base = 32
        }
        return isLandscape ? base / 2 : base
    }

    var body: some View {
        VStack(spacing: 0) {
            ConnectOperatorView(
                style: model.connectStyle.connectOperator,
                state: model.state,
                environment: .init(imageCache: model.imageCache)
            )
            .padding(.top, topPadding)

            statusSection
                .padding(.vertical, contentSpacing)
        }
        .maxWidth()
        .accessibilityElement(children: .contain)
        .onAppear { syncConnectingStart(for: model.state) }
        .onChange(of: model.state) { syncConnectingStart(for: $0) }
    }

    @ViewBuilder
    private var statusSection: some View {
        switch model.state {
        case .connecting:
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                let seconds = elapsedConnectingSeconds(now: context.date)
                ConnectStatusView(
                    firstText: firstText(for: model.state),
                    secondText: String(seconds),
                    connectStyle: connectStatusStyle(for: model.state),
                    secondLineStyle: .connect(connectStatusStyle(for: model.state))
                )
            }
        default:
            ConnectStatusView(
                firstText: firstText(for: model.state),
                secondText: secondText(for: model.state),
                connectStyle: connectStatusStyle(for: model.state),
                secondLineStyle: .connect(connectStatusStyle(for: model.state))
            )
        }
    }

    private func syncConnectingStart(for state: EngagementState) {
        switch state {
        case .connecting:
            if connectingStartDate == nil { connectingStartDate = Date() }
        default:
            connectingStartDate = nil
        }
    }

    private func elapsedConnectingSeconds(now: Date) -> Int {
        guard let start = connectingStartDate else { return 0 }
        return max(0, Int(now.timeIntervalSince(start)))
    }

    private func connectStatusStyle(for state: EngagementState) -> ConnectStatusStyle {
        switch state {
        case .initial, .queue:
            return model.connectStyle.queue
        case .connecting:
            return model.connectStyle.connecting
        case .connected, .onHold:
            return model.connectStyle.connected
        case .transferring:
            return model.connectStyle.transferring
        }
    }

    private func firstText(for state: EngagementState) -> String? {
        switch state {
        case .initial:
            return nil
        case .queue:
            return model.connectStyle.queue.firstText
        case let .connecting(name, _):
            return model.connectStyle.connecting.firstText?.withOperatorName(name)
        case .connected(let name, _), let .onHold(name, _, _, _):
            return model.connectStyle.connected.firstText?.withOperatorName(name)
        case .transferring:
            return model.connectStyle.transferring.firstText
        }
    }

    private func secondText(for state: EngagementState) -> String? {
        switch state {
        case .initial:
            return nil
        case .queue:
            return model.connectStyle.queue.secondText
        case .connecting:
            return nil
        case .connected(let name, _), let .onHold(name, _, _, _):
            return model.connectStyle.connected.secondText?.withOperatorName(name)
        case .transferring:
            return model.connectStyle.transferring.secondText
        }
    }
}
