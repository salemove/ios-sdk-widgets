import Foundation

extension CallVisualizer {
    func offerScreenShare(
        from operators: [CoreSdkClient.Operator],
        configuration: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        coordinator?.offerScreenShare(
            from: operators,
            configuration: configuration,
            accepted: accepted,
            declined: declined
        )
    }
}
