extension String {
    func withOperatorName(_ name: String?) -> String {
        let name = name ?? L10n.operator
        return replacingOccurrences(of: "{operatorName}", with: name)
    }

    func withCallDuration(_ duration: String) -> String {
        return replacingOccurrences(of: "{callDuration}", with: duration)
    }

    func withFileSender(_ name: String) -> String {
        return replacingOccurrences(of: "{fileSender}", with: name)
    }

    func withBadgeValue(_ value: String) -> String {
        return replacingOccurrences(of: "{badgeValue}", with: value)
    }

    func withButtonTitle(_ title: String) -> String {
        return replacingOccurrences(of: "{buttonTitle}", with: title)
    }

    func withUploadedFileName(_ fileName: String) -> String {
        replacingOccurrences(of: "{uploadedFileName}", with: fileName)
    }

    func withUploadPercentValue(_ value: String) -> String {
        replacingOccurrences(of: "{uploadPercentValue}", with: value)
    }
}
