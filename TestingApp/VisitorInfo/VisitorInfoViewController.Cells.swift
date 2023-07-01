import UIKit

final class NotesCell: UITableViewCell {
    static var identifier: String { "\(Self.self)" }

    var props: Props = Props(placeholder: "", text: "", textChanged: .nop, textViewAccIdentifier: "") {
        didSet {
            renderProps()
        }
    }

    private lazy var textView = UITextView()
    private lazy var placeholderLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.delegate = self
        contentView.addSubview(textView)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeholderLabel)
        placeholderLabel.textColor = .lightGray

        let margins = 10.0

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margins),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margins),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
        ])
    }

    private func renderProps() {
        if !textView.isFirstResponder {
            textView.text = props.text
        }
        placeholderLabel.text = props.placeholder
        placeholderLabel.isHidden = !props.text.isEmpty || textView.isFirstResponder
        textView.accessibilityIdentifier = props.textViewAccIdentifier
    }
}

extension NotesCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        props.textChanged(textView.text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.isFirstResponder
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !props.text.isEmpty || textView.isFirstResponder
    }
}

extension NotesCell {
    struct Props: Equatable {
        let placeholder: String
        let text: String
        let textChanged: Command<String>
        let textViewAccIdentifier: String
    }
}

final class CustomAttributeCell: UITableViewCell {
    static var identifier: String { "\(Self.self)" }

    var props = Props(
        keyText: "",
        keyUpdate: .nop,
        valueText: "",
        valueUpdate: .nop,
        remove: .nop,
        keyTextFieldAccIdentifier: "",
        valueTextFieldAccIdentifier: ""
    ) {
        didSet {
            renderProps()
        }
    }

    private lazy var keyTextField = UITextField()
    private lazy var valueTextField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        let margins = 10.0
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        keyTextField.borderStyle = .roundedRect
        stackView.addArrangedSubview(keyTextField)
        keyTextField.addTarget(self, action: #selector(handleTextChanged(textField:)), for: .editingChanged)

        valueTextField.borderStyle = .roundedRect
        valueTextField.addTarget(self, action: #selector(handleTextChanged(textField:)), for: .editingChanged)

        stackView.addArrangedSubview(valueTextField)
        stackView.spacing = margins

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margins),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margins)
        ])
    }

    private func renderProps() {
        keyTextField.placeholder = "Key"
        keyTextField.accessibilityIdentifier = props.keyTextFieldAccIdentifier
        valueTextField.placeholder = "Value"
        valueTextField.accessibilityIdentifier = props.valueTextFieldAccIdentifier
        if !keyTextField.isFirstResponder {
            keyTextField.text = props.keyText
        }

        if !valueTextField.isFirstResponder {
            valueTextField.text = props.valueText
        }
    }

    @objc private func handleTextChanged(textField: UITextField) {
        switch textField {
        case self.keyTextField:
            self.props.keyUpdate(textField.text ?? "")
        case self.valueTextField:
            self.props.valueUpdate(textField.text ?? "")
        default:
            break
        }
    }
}

extension CustomAttributeCell {
    struct Props: Equatable {
        let keyText: String
        let keyUpdate: Command<String>
        let valueText: String
        let valueUpdate: Command<String>
        let remove: Cmd
        let keyTextFieldAccIdentifier: String
        let valueTextFieldAccIdentifier: String
    }
}

enum CellType {
    case infoField(InfoFieldCell)
    case notes(NotesCell)
    case customAttribute(CustomAttributeCell)
}

extension CellType {
    init?(_ cell: UITableViewCell) {
        switch cell {
        case let cell as InfoFieldCell:
            self = .infoField(cell)
        case let cell as NotesCell:
            self = .notes(cell)
        case let cell as CustomAttributeCell:
            self = .customAttribute(cell)
        default:
            return nil
        }
    }

    static func renderCell(_ cellType: CellType, infoField: VisitorInfoViewController.Props.InfoField) {
        switch infoField {
        case let .name(label, value, update):
            switch cellType {
            case let .infoField(infoFieldCell):
                infoFieldCell.props = .init(
                    label: label,
                    value: value,
                    change: update,
                    keyboardType: .default,
                    textFieldAccIdentifier: "visitor_info_name_input")
            case .customAttribute, .notes:
                // We do not use attributes, notes cells for name.
                break
            }
        case let .email(label, value, update):
            switch cellType {
            case let .infoField(infoFieldCell):
                infoFieldCell.props = .init(
                    label: label,
                    value: value,
                    change: update,
                    keyboardType: .emailAddress,
                    textFieldAccIdentifier: "visitor_info_email_input"
                )
            case .customAttribute, .notes:
                // We do not use attributes, notes cells for email.
                break
            }
        case let .phoneNumber(label, value, update):
            switch cellType {
            case let .infoField(infoFieldCell):
                infoFieldCell.props = .init(
                    label: label,
                    value: value,
                    change: update,
                    keyboardType: .phonePad,
                    textFieldAccIdentifier: "visitor_info_phone_input"
                )
            case .customAttribute, .notes:
                // We do not use attributes, notes cells for phone number.
                break
            }
        case let .notes(placeholder, text, update):
            switch cellType {
            case let .notes(notesCell):
                notesCell.props = .init(
                    placeholder: placeholder,
                    text: text,
                    textChanged: update,
                    textViewAccIdentifier: "visitor_info_note_input"
                )
            case .customAttribute, .infoField:
                // We do not use attributes, infoField cells for notes.
                break
            }
        case let .customAttributes(pair):
            switch cellType {
            case let .customAttribute(customAttributeCell):
                customAttributeCell.props = .init(
                    keyText: pair.key,
                    keyUpdate: pair.keyUpdate,
                    valueText: pair.value,
                    valueUpdate: pair.valueUpdate,
                    remove: pair.remove,
                    keyTextFieldAccIdentifier: pair.keyFieldAccIdentifier,
                    valueTextFieldAccIdentifier: pair.valueFieldAccIdentifier
                )
            case .infoField, .notes:
                break
            }
        }
    }

    static func dequeueCell(
        for infoField: VisitorInfoViewController.Props.InfoField,
        from tableView: UITableView,
        at indexPath: IndexPath
    ) -> CellType? {
        switch infoField {
        case .name, .email, .phoneNumber:
            return (tableView.dequeueReusableCell(withIdentifier: InfoFieldCell.identifier) as? InfoFieldCell)
                .map(CellType.infoField)
        case .notes:
            return (tableView.dequeueReusableCell(withIdentifier: NotesCell.identifier) as? NotesCell)
                .map(CellType.notes)
        case .customAttributes:
            return (tableView.dequeueReusableCell(withIdentifier: CustomAttributeCell.identifier) as? CustomAttributeCell)
                .map(CellType.customAttribute)
        }
    }

    func cell() -> UITableViewCell {
        switch self {
        case let .infoField(cell):
            return cell
        case let .notes(cell):
            return cell
        case let .customAttribute(cell):
            return cell
        }
    }
}

final class InfoFieldCell: UITableViewCell {
    static var identifier: String { "\(Self.self)" }

    private lazy var textField = UITextField()
    private lazy var titleLabel = UILabel()

    var props = Props(
        label: "",
        value: "",
        change: .nop,
        keyboardType: .default,
        textFieldAccIdentifier: ""
    ) {
        didSet {
            updateProps()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(handleTextChanged(textField:)), for: .editingChanged)

        let margins = 10.0
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: margins, left: margins, bottom: margins, right: margins)
        stackView.spacing = margins
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func updateProps() {
        titleLabel.text = props.label
        textField.keyboardType = props.keyboardType
        if !textField.isFirstResponder {
            textField.text = props.value
        }
        textField.accessibilityIdentifier = props.textFieldAccIdentifier
    }

    @objc func handleTextChanged(textField: UITextField) {
        props.change(textField.text ?? "")
    }
}

extension InfoFieldCell {
    struct Props {
        let label: String
        let value: String
        let change: Command<String>
        let keyboardType: UIKeyboardType
        let textFieldAccIdentifier: String
    }
}
