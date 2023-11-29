import Foundation

extension WebViewController {
    struct Props {
        let link: URL?
        let header: Header.Props
        let externalOpen: Command<URL>

        static var initial: Self {
            .init(
                link: nil,
                header: .init(
                    title: "",
                    effect: .none,
                    endButton: nil,
                    backButton: nil,
                    closeButton: nil,
                    endScreenshareButton: nil,
                    style: Theme().webView.header
                ),
                externalOpen: .nop
            )
        }
    }
}

extension WebViewController {
    typealias Link = (title: String, url: URL)
}
