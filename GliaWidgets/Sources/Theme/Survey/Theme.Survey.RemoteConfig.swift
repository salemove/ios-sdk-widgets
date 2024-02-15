import Foundation

extension Theme.SurveyStyle {
    /// Applies remote configuration to survey.
    mutating func apply(
        configuration: RemoteConfiguration.Survey?,
        assetsBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        layer.apply(configuration: configuration?.layer)
        title.apply(
            configuration: configuration?.title,
            assetsBuilder: assetsBuilder
        )
        submitButton.apply(
            configuration: configuration?.submitButton,
            assetsBuilder: assetsBuilder
        )
        cancelButton.apply(
            configuration: configuration?.cancelButton,
            assetsBuilder: assetsBuilder
        )
        booleanQuestion.apply(
            configuration: configuration?.booleanQuestion,
            assetsBuilder: assetsBuilder
        )
        scaleQuestion.apply(
            configuration: configuration?.scaleQuestion,
            assetsBuilder: assetsBuilder
        )
        singleQuestion.apply(
            configuration: configuration?.singleQuestion,
            assetsBuilder: assetsBuilder
        )
        inputQuestion.apply(
            configuration: configuration?.inputQuestion,
            assetsBuilder: assetsBuilder
        )
    }
}
