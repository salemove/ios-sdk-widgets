import Foundation

extension WebViewController {
    struct Props {
        let link: Link?
        let header: Header.Props?
        let externalOpen: Command<URL>

        static var initial: Self {
            .init(
                link: nil,
                header: nil,
                externalOpen: .nop
            )
        }
    }
}

extension WebViewController {
    typealias Link = (title: String, url: URL)
}
