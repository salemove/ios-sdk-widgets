import SwiftUI

struct FontPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fontName: String
    @State private var fontSize: CGFloat
    @State private var fontWeight: UIFont.Weight
    @Binding var selectedFont: UIFont

    let title: String
    private let availableFonts = UIFont.familyNames.sorted()
    private let weights: [UIFont.Weight] = [
        .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black
    ]

    init(
        title: String,
        selectedFont: Binding<UIFont>
    ) {
        self.title = title
        self._selectedFont = selectedFont
        self._fontName = State(initialValue: selectedFont.wrappedValue.familyName)
        self._fontSize = State(initialValue: selectedFont.wrappedValue.pointSize)
        self._fontWeight = State(initialValue: .regular)
    }

    var body: some View {
        Form {
            Section("Preview", content: previewSection)
            Section("Font Family", content: familySection)
            Section("Size", content: sizeSection)
            Section("Weight", content: weightSection)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .topBarTrailing,
                content: doneButton
            )
            ToolbarItem(
                placement: .principal,
                content: titleView
            )
        }
        .onChange(of: fontName) { _ in updateFont() }
        .onChange(of: fontSize) { _ in updateFont() }
        .onChange(of: fontWeight) { _ in updateFont() }
    }
}

private extension FontPickerView {
    @ViewBuilder
    func doneButton() -> some View {
        Button("Done") {
            saveFont()
            dismiss()
        }
        .font(.system(size: 17, weight: .semibold))
    }

    @ViewBuilder
    func titleView() -> some View {
       TitleView(title: title)
    }

    @ViewBuilder
    func previewSection() -> some View {
        Text("The quick brown fox jumps over the lazy dog")
            .font(Font(selectedFont))
            .padding()
    }

    @ViewBuilder
    func familySection() -> some View {
        Picker("Font", selection: $fontName) {
            ForEach(availableFonts, id: \.self) { family in
                Text(family).tag(family)
            }
        }
    }

    @ViewBuilder
    func sizeSection() -> some View {
        Stepper(value: $fontSize, in: 8...72, step: 1) {
            HStack {
                Text("Size")
                Spacer()
                Text("\(Int(fontSize)) pt")
                    .setColor(.secondary)
            }
        }
    }

    @ViewBuilder
    func weightSection() -> some View {
        Picker("Weight", selection: $fontWeight) {
            Text("Ultra Light").tag(UIFont.Weight.ultraLight)
            Text("Thin").tag(UIFont.Weight.thin)
            Text("Light").tag(UIFont.Weight.light)
            Text("Regular").tag(UIFont.Weight.regular)
            Text("Medium").tag(UIFont.Weight.medium)
            Text("Semibold").tag(UIFont.Weight.semibold)
            Text("Bold").tag(UIFont.Weight.bold)
            Text("Heavy").tag(UIFont.Weight.heavy)
            Text("Black").tag(UIFont.Weight.black)
        }
    }
}

private extension FontPickerView {
    func updateFont() {
        if let font = UIFont(name: fontName, size: fontSize) {
            selectedFont = font
        } else {
            selectedFont = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
    }

    func saveFont() {
        updateFont()
    }
}
