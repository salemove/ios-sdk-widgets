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

    func offerMediaUpgrade(
        from operators: [CoreSdkClient.Operator],
        offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let alertConfiguration = Theme().alertConfiguration
        switch offer.type {
        case .video:
            let configuration = offer.direction == .oneWay
                ? alertConfiguration.oneWayVideoUpgrade
                : alertConfiguration.twoWayVideoUpgrade
            coordinator?.offerMediaUpgrade(
                from: operators,
                configuration: configuration,
                accepted: accepted,
                declined: declined
            )
        default:
            break
        }
    }
}
