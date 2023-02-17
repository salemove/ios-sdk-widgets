import UIKit

#if DEBUG

//
// This structures are created to use during development (DEBUG flag)
//  and have possibility without exposing internal classes/components
//  present them somewhere on UI and verify appearance in different
//  states.
//

public struct ViewPlaybook {
    public let title: String
    public let preview: () -> UIView
}

extension ViewPlaybook {
    static let standardTheme = Theme()

    public static let all: [ViewPlaybook] = [
        .init(title: "Chat: Header") {
            UIStackView.make(.vertical, spacing: 16)(
                chat,
                call,
                UIView()
            )
        }
    ]

    static var chat: Header {
        let header = Header(
            props: .init(
                title: "Chat",
                effect: .none,
                endButton: .init(
                    style: standardTheme.chat.header.endButton,
                    title: "#endButton#"
                ),
                backButton: .init(style: standardTheme.chat.header.backButton),
                closeButton: .init(style: standardTheme.chat.header.closeButton),
                endScreenshareButton: .init(style: standardTheme.chat.header.endScreenShareButton),
                style: standardTheme.chat.header
            )
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            header.props = .createNewProps(with: "Messaging", props: header.props)
        }

        return header
    }

    static var call: Header {
        let header = Header(
            props: .init(
                title: "Audio Call",
                effect: .blur,
                endButton: .init(
                    style: standardTheme.call.header.endButton,
                    title: "#endButton#"
                ),
                backButton: .init(style: standardTheme.call.header.backButton),
                closeButton: .init(style: standardTheme.call.header.closeButton),
                endScreenshareButton: .init(style: standardTheme.call.header.endScreenShareButton),
                style: standardTheme.call.header
            )
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            header.props = .createNewProps(with: "Video Call", props: header.props)
        }

        return header
    }
}

extension Header.Props {
    static func createNewProps(with newTitle: String, props: Header.Props) -> Header.Props {
        Header.Props(
            title: newTitle,
            effect: props.effect,
            endButton: props.endButton,
            backButton: props.backButton,
            closeButton: props.closeButton,
            endScreenshareButton: props.endScreenshareButton,
            style: props.style
        )
    }
}

#endif
