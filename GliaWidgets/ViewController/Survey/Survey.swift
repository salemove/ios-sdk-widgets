import Foundation

enum Survey {
    typealias QuestionPropsProtocol = SurveyQuestionPropsProtocol

    struct Option<Value: Equatable>: Equatable {
        let name: String
        let value: Value
        var select: (Self) -> Void = { _ in }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name && lhs.value == rhs.value
        }
    }
}

protocol SurveyQuestionPropsProtocol {
    var id: String { get }
    var isValid: Bool { get }
    var showValidationError: Bool { get set }
    var answerContainer: CoreSdkClient.SurveyAnswerContainer? { get set }
}
