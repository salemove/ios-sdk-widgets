import UIKit

class SettingsFontCell: SettingsCell {
    var selectedFont: UIFont {
        let size = CGFloat(SettingsFontCell.kFontSizes[pickerView.selectedRow(inComponent: 1)])
        let fontIndex = pickerView.selectedRow(inComponent: 0)

        let font: UIFont = {
            if fontIndex == 0 {
                return defaultFont.withSize(size)
            } else {
                return SettingsFontCell.kFonts[fontIndex - 1].withSize(size)
            }
        }()

        return font
    }

    private let pickerView = UIPickerView()
    private let defaultFont: UIFont
    private static let kFontSizes: [CGFloat] = Array(stride(from: 8.0, through: 30.0, by: 1.0))
    private static let kFonts: [UIFont] = {
        let fontNames = UIFont.familyNames
            .flatMap({ UIFont.fontNames(forFamilyName: $0) })
        let fonts = fontNames
            .compactMap({ UIFont(name: $0, size: 15) })
        return fonts
    }()

    init(title: String, defaultFont: UIFont) {
        self.defaultFont = defaultFont
        super.init(title: title)
        setup()
        layout()
    }

    private func setup() {
        pickerView.dataSource = self
        pickerView.delegate = self

        selectDefaultFont()
    }

    private func layout() {
        contentView.addSubview(pickerView)
        pickerView.autoSetDimensions(to: CGSize(width: 230, height: 100))
        pickerView.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 10)
        pickerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
                                               excludingEdge: .left)
    }

    private func selectDefaultFont() {
        pickerView.selectRow(0, inComponent: 0, animated: false)

        let sizeIndex = SettingsFontCell.kFontSizes
            .enumerated()
            .first(where: { $0.element == defaultFont.pointSize })?
            .offset

        if let index = sizeIndex {
            pickerView.selectRow(index, inComponent: 1, animated: false)
        }

        updateSample()
    }

    private func updateSample() {
        titleLabel.font = selectedFont
    }
}

extension SettingsFontCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return SettingsFontCell.kFonts.count + 1
        case 1:
            return SettingsFontCell.kFontSizes.count
        default:
            return 0
        }
    }
}

extension SettingsFontCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 200
        case 1:
            return 30
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true

        switch component {
        case 0:
            if row == 0 {
                titleLabel.text = "Default"
            } else {
                titleLabel.text = SettingsFontCell.kFonts[row - 1].fontName
            }
        case 1:
            titleLabel.text = String(describing: SettingsFontCell.kFontSizes[row])
        default:
            break
        }

        return titleLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateSample()
    }
}
