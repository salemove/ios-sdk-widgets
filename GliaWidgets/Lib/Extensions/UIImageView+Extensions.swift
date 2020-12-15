import UIKit

extension UIImageView {
    func setImage(from url: String?, animated: Bool, finished: ((UIImage?) -> Void)?) {
        guard let urlString = url, let url = URL(string: urlString) else {
            image = nil
            finished?(nil)
            return
        }
        DispatchQueue.global().async {
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                self.image = nil
                finished?(nil)
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.transition(with: self,
                                  duration: animated ? 0.2 : 0.0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.image = image
                                  }, completion: nil)
                finished?(image)
            }
        }
    }
}
