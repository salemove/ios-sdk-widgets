import WebKit

final class WebViewController: UIViewController {
    var props: Props {
        didSet {
            renderProps()
        }
    }
    private lazy var header = Header()
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    init(props: Props = .initial) {
        self.props = props
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadRequest()
    }
}

// MARK: - Private

private extension WebViewController {
    @objc
    func close() {
        dismiss(animated: true)
    }

    func setup() {
        view.addSubview(header)
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += header.layoutInSuperview(edges: .horizontal)
        constraints += header.layoutInSuperview(edges: .top)

        view.addSubview(webView)
        constraints += webView.layoutInSuperview(edges: .horizontal)
        constraints += webView.layoutInSuperview(edges: .bottom)
        constraints += webView.topAnchor.constraint(equalTo: header.bottomAnchor)
    }

    func loadRequest() {
        guard let url = props.link?.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func renderProps() {
        guard let headerProps = props.header else { return }
        header.props = headerProps
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        // WKNavigationType.other is received when the navigation url is assigned programatically
        // or server-side redirection occurred.
        // All further user navigation should be redirected to external browser.
        if navigationAction.navigationType == .other {
            decisionHandler(.allow)
        } else {
            props.externalOpen(url)
            decisionHandler(.cancel)
        }
    }
}
