import UIKit

extension ChatView {
    private static var unreadMessageIndicatorInset: CGFloat = -3

    // swiftlint:disable:next function_body_length
    func setupConstraints() {
        addSubview(header)
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += header.layoutInSuperview(edges: .horizontal)
        constraints += header.layoutInSuperview(edges: .top)

        typingIndicatorContainer.addSubview(typingIndicatorView)
        typingIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        tableAndIndicatorStack.addArrangedSubviews([tableView, typingIndicatorContainer])
        addSubview(tableAndIndicatorStack)
        tableAndIndicatorStack.translatesAutoresizingMaskIntoConstraints = false
        constraints += tableAndIndicatorStack.layoutInSuperview(edges: .horizontal)
        addSubview(topContentShadowView)
        topContentShadowView.translatesAutoresizingMaskIntoConstraints = false
        constraints += [
            topContentShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topContentShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topContentShadowView.topAnchor.constraint(equalTo: tableAndIndicatorStack.topAnchor),
            topContentShadowView.heightAnchor.constraint(equalToConstant: 12)
        ]
        topContentShadowView.isUserInteractionEnabled = false
        topContentShadowView.backgroundColor = .clear
        if topContentShadowGradient.superlayer == nil {
            topContentShadowView.layer.addSublayer(topContentShadowGradient)
        }

        constraints += [
            typingIndicatorView.leadingAnchor.constraint(equalTo: typingIndicatorContainer.leadingAnchor, constant: 10),
            typingIndicatorView.topAnchor.constraint(equalTo: typingIndicatorContainer.topAnchor, constant: 10),
            typingIndicatorView.bottomAnchor.constraint(equalTo: typingIndicatorContainer.bottomAnchor, constant: -8),
            typingIndicatorView.widthAnchor.constraint(equalToConstant: 28),
            typingIndicatorView.heightAnchor.constraint(equalToConstant: 10)
        ]

        addSubview(secureMessagingTopBannerView)
        constraints += secureMessagingTopBannerView.layoutIn(safeAreaLayoutGuide, edges: .horizontal)
        constraints += [
            secureMessagingTopBannerView.topAnchor.constraint(equalTo: header.bottomAnchor),
            secureMessagingTopBannerView.bottomAnchor.constraint(equalTo: tableAndIndicatorStack.topAnchor)
        ]

        addSubview(entryWidgetContainerView)
        let entryWidgetContainerViewHeightConstraint = entryWidgetContainerView.heightAnchor.constraint(equalToConstant: 0)
        constraints += entryWidgetContainerView.layoutIn(safeAreaLayoutGuide, edges: .horizontal)
        constraints += [
            entryWidgetContainerView.topAnchor.constraint(equalTo: secureMessagingTopBannerView.bottomAnchor),
            entryWidgetContainerViewHeightConstraint
        ]
        self.entryWidgetContainerViewHeightConstraint = entryWidgetContainerViewHeightConstraint

        addSubview(entryWidgetOverlayView)
        constraints += entryWidgetOverlayView.layoutInSuperview(edges: .horizontal)
        constraints += [
            entryWidgetOverlayView.topAnchor.constraint(equalTo: secureMessagingTopBannerView.bottomAnchor),
            entryWidgetOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        addSubview(quickReplyView)
        constraints += quickReplyView.layoutIn(safeAreaLayoutGuide, edges: .horizontal)
        constraints += quickReplyView.topAnchor.constraint(equalTo: tableAndIndicatorStack.bottomAnchor)

        addSubview(secureMessagingBottomBannerView)
        constraints += [
            secureMessagingBottomBannerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            secureMessagingBottomBannerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            secureMessagingBottomBannerView.topAnchor.constraint(equalTo: quickReplyView.bottomAnchor)
        ]

        addSubview(sendingMessageUnavailabilityBannerView)
        constraints += [
            sendingMessageUnavailabilityBannerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            sendingMessageUnavailabilityBannerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            sendingMessageUnavailabilityBannerView.topAnchor.constraint(equalTo: secureMessagingBottomBannerView.bottomAnchor)
        ]

        addSubview(messageEntryView)
        let messageEntryInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 4.5,
            right: 0
        )
        messageEntryViewBottomConstraint = messageEntryView.layoutIn(
            safeAreaLayoutGuide,
            edges: .bottom,
            insets: messageEntryInsets
        ).first
        if let messageEntryViewBottomConstraint {
            constraints += messageEntryViewBottomConstraint
        }

        constraints += messageEntryView.layoutIn(safeAreaLayoutGuide, edges: .horizontal)
        constraints += messageEntryView.topAnchor.constraint(equalTo: sendingMessageUnavailabilityBannerView.bottomAnchor)

        addSubview(unreadMessageIndicatorView)
        unreadMessageIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        constraints += unreadMessageIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)

        constraints += unreadMessageIndicatorView.bottomAnchor.constraint(
            equalTo: messageEntryView.topAnchor, constant: Self.unreadMessageIndicatorInset
        )

        bringSubviewToFront(entryWidgetOverlayView)
        bringSubviewToFront(entryWidgetContainerView)

        constraints += [
            messageEntryBottomArea.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            messageEntryBottomArea.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            messageEntryBottomArea.topAnchor.constraint(equalTo: messageEntryView.bottomAnchor),
            messageEntryBottomArea.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ]
        insertSubview(messageEntryBottomArea, at: 0)
    }
}
