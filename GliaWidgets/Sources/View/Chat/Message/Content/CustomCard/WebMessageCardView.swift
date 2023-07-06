import UIKit
import WebKit

private extension String {
    static let readyState = "document.readyState"
    static let bodyHeight = "document.body.scrollHeight"
    static let bodyWidth = "document.body.scrollWidth"

    static let separator = "@@"
    static let gliaDomain = "gliaSdk"
    static let responseOptionScript = """
        function sendResponse(selectedText, selectedValue) {
            window.webkit.messageHandlers.\(gliaDomain).postMessage(`${selectedText}\(separator)${selectedValue}`);
        }
    """
    static let mobileOptionScript = """
        function callMobileAction(action) {
            window.webkit.messageHandlers.\(gliaDomain).postMessage(`${action}`);
        }
    """
    static let disableZooming = """
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        var head = document.getElementsByTagName('head')[0];
        head.appendChild(meta);
    """
}

protocol WebMessageCardViewDelegate: AnyObject {
    func viewDidUpdateHeight(
        _ view: WebMessageCardView,
        height: CGFloat,
        for messageId: MessageRenderer.Message.Identifier
    )

    func didSelectCustomCardOption(
        _ view: WebMessageCardView,
        selectedOption: HtmlMetadata.Option,
        for messageId: MessageRenderer.Message.Identifier
    )

    func didCallMobileAction(
        _ view: WebMessageCardView,
        action: String
    )

    func didSelectURL(
        _ view: WebMessageCardView,
        url: URL
    )
}

final class WebMessageCardView: UIView {

    private enum ActionType: Int {
        case mobileAction = 1
        case cardOption
    }

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        // Script used to disable zooming HTML content
        let zoomingScript = WKUserScript(
            source: .disableZooming,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(zoomingScript)
        // Script is used to handle JS response card actions
        let responseOptionScript = WKUserScript(
            source: .responseOptionScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        // Script is used to handle JS mobile actions (string-based url-schemes)
        let mobileOptionScript = WKUserScript(
            source: .mobileOptionScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )

        config.userContentController.addUserScript(responseOptionScript)
        config.userContentController.addUserScript(mobileOptionScript)
        config.userContentController.add(self, name: .gliaDomain)
        return WKWebView(
            frame: .zero,
            configuration: config
        )
    }()

    private let policyProvider: WKNavigationPolicyProvider
    private let message: MessageRenderer.Message
    private let metadata: HtmlMetadata
    private var heightConstraint: NSLayoutConstraint?

    var delegate: WebMessageCardViewDelegate?

    init(
        policyProvider: WKNavigationPolicyProvider,
        message: MessageRenderer.Message,
        metadata: HtmlMetadata
    ) {
        self.policyProvider = policyProvider
        self.message = message
        self.metadata = metadata
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeight(_ height: CGFloat) {
        heightConstraint?.constant = height
    }

    func startLoading() {
        loadWebView()
    }
}

// MARK: - Private

private extension WebMessageCardView {
    func setup() {
        webView.navigationDelegate = self
    }

    func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        heightConstraint = webView.match(.height, value: 0).first
        heightConstraint.map { constraints += $0 }
        addSubview(webView)
        constraints += webView.layoutInSuperview()
    }

    func loadWebView() {
        webView.loadHTMLString(metadata.html, baseURL: nil)
    }

    func handleMobileAction(_ components: [String]) {
        guard let action = components.first else { return }
        delegate?.didCallMobileAction(
            self,
            action: action
        )
    }

    func handleResponseOption(_ components: [String]) {
        guard
            let text = components.first,
            let value = components.last
        else { return }

        isUserInteractionEnabled = false
        delegate?.didSelectCustomCardOption(
            self,
            selectedOption: .init(
                text: text,
                value: value
            ),
            for: self.message.id
        )
    }
}

// MARK: - WKScriptMessageHandler

extension WebMessageCardView: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            message.name == .gliaDomain,
            let body = message.body as? String
        else { return }

        let components = body.components(separatedBy: String.separator)

        guard let actionType = ActionType(rawValue: components.count) else { return }

        switch actionType {
        case .mobileAction:
            handleMobileAction(components)
        case .cardOption:
            handleResponseOption(components)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebMessageCardView: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        self.webView.evaluateJavaScript(.readyState) { [weak self] complete, _ in
            guard complete != nil else { return }
            self?.webView.evaluateJavaScript(.bodyHeight) { height, _ in
                guard
                    let self = self,
                    let value = height as? CGFloat
                else { return }
                self.updateHeight(value)
                self.delegate?.viewDidUpdateHeight(
                    self,
                    height: value,
                    for: self.message.id
                )
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let result = policyProvider.policy(url)
        if result.shouldHandleUrlSelection {
            delegate?.didSelectURL(self, url: url)
        }
        decisionHandler(result.policy)
    }
}
