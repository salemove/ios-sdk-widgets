import UIKit

class ImageView: UIImageView {
    var downloadID: String = ""

    func setImage(_ image: UIImage?, animated: Bool) {
        UIView.transition(with: self,
                          duration: animated ? 0.2 : 0.0,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.image = image
                          }, completion: nil)
    }

    func setImage(from url: String?, animated: Bool, finished: ((UIImage?) -> Void)?) {
        guard
            let urlString = url,
            let url = URL(string: urlString)
        else {
            setImage(nil, animated: animated)
            finished?(nil)
            return
        }

        let downloadID = UUID().uuidString
        self.downloadID = downloadID
        
        DispatchQueue.global().async { [weak self] in
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                self?.setImage(nil, animated: animated)
                finished?(nil)
                return
            }
            DispatchQueue.main.async {
                guard self?.downloadID == downloadID else { return }
                self?.setImage(image, animated: animated)
                finished?(image)
            }
        }
    }
}
