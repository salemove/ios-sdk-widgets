import UIKit

protocol DismissalAndPresentationController where Self: UIViewController {
    func replacePresentedOfferIfPossible(with offer: Replaceable)
}

extension DismissalAndPresentationController {
    func replacePresentedOfferIfPossible(with offer: Replaceable) {
        let completion = { [unowned self] in
            self.present(offer, animated: true)
        }
        guard let presented = self.presentedViewController as? Replaceable else {
            completion()
            return
        }
        if presented.isReplaceable(with: offer) {
            presented.dismiss(animated: true, completion: completion)
        }
    }
}
