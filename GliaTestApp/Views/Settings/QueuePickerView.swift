import SwiftUI
import GliaWidgets

struct QueuePickerView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    let queues: [Queue]
    let isLoading: Bool
    let error: String?
    @Binding var selectedQueueId: String

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    loadingView()
                } else if let error = error {
                    errorView(error: error)
                } else if queues.isEmpty {
                    emptyView()
                } else {
                    contentView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .navigationBarTrailing,
                    content: doneButton
                )
                ToolbarItem(
                    placement: .principal,
                    content: titleView
                )
            }
        }
    }
}

private extension QueuePickerView {
    @ViewBuilder
    func titleView() -> some View {
        TitleView(title: "Select Queue")
    }

    @ViewBuilder
    func loadingView() -> some View {
        ProgressView("Loading queues...")
    }

    @ViewBuilder
    func errorView(error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .setColor(.orange)
            Text("Failed to load queues")
                .font(.headline)
            Text(error)
                .font(.caption)
                .setColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    func emptyView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .setColor(.secondary)
            Text("No queues available")
                .font(.headline)
        }
    }

    @ViewBuilder
    func contentView() -> some View {
        List(queues, id: \.id) { queue in
            Button {
                selectedQueueId = queue.id
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(queue.name)
                            .font(.body)
                            .setColor(.primary)
                        Text(queue.id)
                            .font(.caption)
                            .setColor(.secondary)
                    }
                    Spacer()
                    if queue.id == selectedQueueId {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func doneButton() -> some View {
        Button("Done") {
            dismiss()
        }
    }
}
