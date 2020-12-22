import UIKit

public final class KeyboardObserver {
    public struct Properties {
        public let duration: Double
        public let finalFrame: CGRect
        public let animationOptions: UIView.AnimationOptions

        public init?(with notification: Notification) {
            guard
                let userInfo = notification.userInfo,
                let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
                let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
                let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else { return nil }
            let curve = animationCurve.uintValue << 16
            duration = animationDuration.doubleValue
            finalFrame = frameEnd.cgRectValue
            animationOptions = UIView.AnimationOptions(rawValue: curve)
        }
    }

    public var currentKeyboardHeight: CGFloat = 0
    public var keyboardWillShow: ((Properties) -> Void)?
    public var keyboardWillHide: ((Properties) -> Void)?

    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector:
            #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let properties = Properties(with: notification) else { return }
        currentKeyboardHeight = properties.finalFrame.height
        keyboardWillShow?(properties)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        guard let properties = Properties(with: notification) else { return }
        currentKeyboardHeight = 0
        keyboardWillHide?(properties)
    }
}
