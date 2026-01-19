import SwiftUI

struct CallConnectView: View {
    @SwiftUI.Environment(\.verticalSizeClass) private var verticalSizeClass
    @SwiftUI.State private var connectingStartDate: Date?
    @ObservedObject var model: CallConnectViewHost.Model

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var topPadding: CGFloat {
        let base: CGFloat
        switch model.state {
        case .connected, .onHold: base = 72
        default: base = 54
        }
        return isLandscape ? base / 2 : base
    }

    private var shouldShowOperatorImage: Bool {
        switch model.state {
        case .onHold:
            return true
        default:
            return model.mode != .video
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if shouldShowOperatorImage {
                ConnectOperatorView(
                    style: model.connectStyle.connectOperator,
                    state: model.state,
                    environment: .init(imageCache: model.imageCache)
                )
            }
            statusSection
                .padding(.top, contentSpacing(for: model.state))

            Spacer(minLength: 0)
        }
        .padding(.top, topPadding)
        .maxWidth()
        .accessibilityElement(children: .contain)
        .onAppear { syncConnectingStart(for: model.state) }
        .onChange(of: model.state) { syncConnectingStart(for: $0) }
    }

    // MARK: - Status section (includes connecting timer)

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
                secondLineStyle: secondLineStyle(for: model.state)
            )
        }
    }

    private func syncConnectingStart(for state: EngagementState) {
        switch state {
        case .connecting:
            if connectingStartDate == nil {
                connectingStartDate = Date()
            }
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
        case .connected:
            return model.connectStyle.connected
        case .transferring:
            return model.connectStyle.transferring
        case .onHold:
            return model.connectStyle.onHold
        }
    }

    private func secondLineStyle(for state: EngagementState) -> ConnectStatusView.SecondLineStyle {
        switch state {
        case .connected:
            return .duration(
                callStyle: model.callStyle,
                hint: model.durationHint ?? model.connectStyle.connected.accessibility.secondTextHint
            )
        default:
            return .connect(connectStatusStyle(for: state))
        }
    }

    private func firstText(for state: EngagementState) -> String? {
        switch state {
        case .initial:
            return nil
        case .queue:
            return model.connectStyle.queue.firstText
        case .connecting(let name, _):
            return model.connectStyle.connecting.firstText?.withOperatorName(name)
        case .connected(let name, _):
            return model.connectStyle.connected.firstText?.withOperatorName(name)
        case .transferring:
            return model.connectStyle.transferring.firstText
        case .onHold(_, _, let onHoldText, _):
            return onHoldText
        }
    }

    private func secondText(for state: EngagementState) -> String? {
        switch state {
        case .initial:
            return nil
        case .queue:
            return model.connectStyle.queue.secondText
        case .connecting:
            return nil // TimelineView renders seconds
        case .connected:
            return model.durationText
        case .transferring:
            return model.connectStyle.transferring.secondText
        case .onHold(_, _, _, let descriptionText):
            return descriptionText
        }
    }

    private func contentSpacing(for state: EngagementState) -> CGFloat {
        guard shouldShowOperatorImage else { return 0 }
        let base: CGFloat
        switch state {
        case .connected, .onHold:
            base = 16
        default:
            base = 32
        }
        return isLandscape ? base / 2 : base
    }
}
