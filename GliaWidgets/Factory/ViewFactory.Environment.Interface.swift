import Foundation

extension ViewFactory {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
        var imageViewCache: ImageView.Cache
    }
}
