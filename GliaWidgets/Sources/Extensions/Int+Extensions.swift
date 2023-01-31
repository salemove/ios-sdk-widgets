extension Int {
    var asDurationString: String {
        let hours = self / 3600
        var remainingSeconds = self - (hours * 3600)
        let minutes = remainingSeconds / 60
        remainingSeconds -= (minutes * 60)

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }
}
