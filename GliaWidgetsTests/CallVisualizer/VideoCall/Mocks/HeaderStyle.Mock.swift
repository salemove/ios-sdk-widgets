#if DEBUG

extension HeaderStyle {
    static let mock = Self(
        titleFont: .font(weight: .regular, size: 12),
        titleColor: .white,
        backgroundColor: .fill(color: .white),
        backButton: .mock,
        closeButton: .mock,
        endButton: .mock,
        endScreenShareButton: .mock
    )
}

extension HeaderButtonStyle {
    static let mock = Self(image: .mock, color: .white)
}

extension ActionButtonStyle {
    static let mock = Self(
        title: "",
        titleFont: .font(weight: .regular, size: 12),
        titleColor: .white,
        backgroundColor: .fill(color: .white)
    )
}

#endif
