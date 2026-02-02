import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .setColor(.primary)
            .maxWidth(alignment: .leading)
            .padding(.horizontal, 4)
    }
}
