import UIKit
import WebKit

private extension String {
    static let readyState = "document.readyState"
    static let bodyHeight = "document.body.scrollHeight"
    static let bodyWidth = "document.body.scrollWidth"

    static let separator = "@@"
    static let gliaDomain = "gliaSdk"
    static let js = """
        function sendResponse(selectedText, selectedValue) {
            window.webkit.messageHandlers.\(gliaDomain).postMessage(`${selectedText}\(separator)${selectedValue}`);
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

    func didSelectURL(
        _ view: WebMessageCardView,
        url: URL
    )
}

final class WebMessageCardView: UIView {

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        // Script used to disable zooming HTML content
        let zoomingScript = WKUserScript(
            source: .disableZooming,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(zoomingScript)
        // Script used to handle JS actions
        let jsScript = WKUserScript(
            source: .js,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(jsScript)
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
        heightConstraint = webView.autoSetDimension(.height, toSize: 0)
        addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
    }

    func loadWebView() {
        webView.loadHTMLString(metadata.html, baseURL: nil)
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
