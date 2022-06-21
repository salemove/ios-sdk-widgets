//
//  Glia.Hacko.swift
//  GliaWidgets
//
//  Created by Yurii Dukhovnyi on 16.06.2022.
//

import Foundation
import UIKit

extension Glia {

    public func startEngagementWithConfig(
        engagement: EngagementKind,
        config: RemoteConfig
    ) throws {

        let theme = Theme()

        theme.chat.header.backgroundColor = config.navigationBar.layer.background
        theme.chat.header.titleColor = config.navigationBar.title.foreground
        theme.chat.header.titleFont = Font.regular(config.navigationBar.title.fontSize)
        theme.chat.backgroundColor = config.layer.background

        theme.chat.visitorMessage.text.backgroundColor = config.visitorMessage.layer.background
        theme.chat.visitorMessage.text.textColor = config.visitorMessage.text.foreground
        theme.chat.visitorMessage.text.textFont = Font.regular(config.visitorMessage.text.fontSize)
        theme.chat.visitorMessage.text.cornerRadius = config.visitorMessage.layer.cornerRadius

        theme.chat.operatorMessage.text.backgroundColor = config.operatorMessage.layer.background
        theme.chat.operatorMessage.text.textColor = config.operatorMessage.text.foreground
        theme.chat.operatorMessage.text.textFont = Font.regular(config.operatorMessage.text.fontSize)
        theme.chat.operatorMessage.text.cornerRadius = config.operatorMessage.layer.cornerRadius

        theme.chat.messageEntry.sendButton.color = config.textField.tintColor
        theme.chat.messageEntry.placeholderColor = config.textField.text.foreground
        theme.chat.messageEntry.backgroundColor = config.textField.layer.background

        theme.chat.connect.queue.firstText = config.welcomeView.titleValue
        theme.chat.connect.queue.firstTextFont = Font.bold(config.welcomeView.title.fontSize)
        theme.chat.connect.queue.firstTextFontColor = config.welcomeView.title.foreground

        theme.chat.connect.queue.secondText = config.welcomeView.descriptionValue
        theme.chat.connect.queue.secondTextFont = Font.regular(config.welcomeView.description.fontSize)
        theme.chat.connect.queue.secondTextFontColor = config.welcomeView.description.foreground

        theme.chat.connect.connectOperator.operatorImage.placeholderBackgroundColor = config.welcomeView.tintColor

        try startEngagement(
            engagementKind: engagement,
            theme: theme,
            features: .all,
            sceneProvider: nil
        )
    }

    public func startEngagementWithRemoteConfig(
        engagement: EngagementKind
    ) throws {
        withGliaHubConfig { [weak self] config in
            do {
                try self?.startEngagementWithConfig(engagement: engagement, config: config)
            } catch {
                print("💥 \(error)")
            }
        }
    }
}














func withGliaHubConfig(completion: @escaping (Glia.RemoteConfig) -> Void) {
    let uuid = "59686f3b-c17f-4e97-bbc2-c0df7ad288ff"
    var urlRequest = URLRequest(url: .init(string: "https://cached-app.herokuapp.com/cached/\(uuid)")!)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
        guard let data = data else { return }
        do {
            let config = try JSONDecoder().decode(Glia.RemoteConfig.self, from: data)
            DispatchQueue.main.async {
                completion(config)
            }
        } catch {
            print("\(error)")
        }
    }
    dataTask.resume()
}
