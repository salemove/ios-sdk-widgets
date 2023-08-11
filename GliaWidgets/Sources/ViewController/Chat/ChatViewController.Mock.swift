#if DEBUG
import Foundation
import UIKit
import GliaCoreSDK

// swiftlint:disable function_body_length
extension ChatViewController {
    static func mock(
        chatViewModel: ChatViewModel = .mock(),
        viewFactory: ViewFactory = .mock()
    ) -> ChatViewController {
        ChatViewController(
            viewModel: .chat(chatViewModel),
            viewFactory: viewFactory
        )
    }

    // MARK: - Empty State
    static func mockEmptyScreen() -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        return .mock(chatViewModel: chatViewModel)
    }

    // MARK: - Enqueue State
    static func mockEnqueueScreen() -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        return .mock(chatViewModel: chatViewModel)
    }

    // MARK: - Messages from Chat Storage
    static func mockHistoryMessagesScreen() -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        var fileManager = FoundationBased.FileManager.mock
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        chatViewModelEnv.fileManager = fileManager
        let createFileDownload = chatViewModelEnv.createFileDownload
        var thumbnailGeneratorMock = QuickLookBased.ThumbnailGenerator.mock
        thumbnailGeneratorMock.generateBestRepresentation = { _, completion in
            var thubmnailMock = QuickLookBased.ThumbnailRepresentation.mock
            thubmnailMock.uiImage = .mock
            completion(thubmnailMock, nil)
        }
        chatViewModelEnv.createFileDownload = { file, storage, env in
            let fileDownload = createFileDownload(file, storage, env)
            var localFileEnv = LocalFile.Environment.mock
            localFileEnv.thumbnailGenerator = thumbnailGeneratorMock
            localFileEnv.gcd.globalQueue = .init(async: { $0() }, asyncAfterDeadline: { $1() })
            localFileEnv.gcd.mainQueue = .init(async: { $0() }, asyncIfNeeded: { $0() }, asyncAfterDeadline: { $1() })
            fileDownload.state.value = .downloaded(
                .mock(
                    url: .mockFilePath.appendingPathComponent(file.url?.lastPathComponent ?? ""),
                    environment: localFileEnv
                )
            )
            return fileDownload
        }

        let messageUuid = UUID.incrementing
        let messageId = { messageUuid().uuidString }
        let fileUuid = UUID.incrementing
        let fileId = { fileUuid().uuidString }
        let queueId = UUID.mock.uuidString
        let operatorAttachmentURL = URL.mock.appendingPathComponent("image").appendingPathExtension("png")

        let messages: [ChatMessage] = [
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: nil,
                sender: .visitor,
                content: "Hi",
                attachment: nil,
                downloads: []
            ),
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: .mock(name: "John Smith", pictureUrl: URL.mock.absoluteString),
                sender: .operator,
                content: "hello",
                attachment: nil,
                downloads: []
            ),
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: nil,
                sender: .visitor,
                content: "",
                attachment: .mock(
                    type: .files,
                    files: [
                        .mock(
                            id: fileId(),
                            url: .mock,
                            name: "File 1.pdf",
                            size: 1024,
                            contentType: "application/pdf",
                            isDeleted: false
                        )
                    ],
                    imageUrl: nil,
                    options: nil,
                    selectedOption: nil
                ),
                downloads: []
            ),
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: nil,
                sender: .visitor,
                content: "Message along with content",
                attachment: .mock(
                    type: .files,
                    files: [
                        .mock(
                            id: fileId(),
                            url: .mockFilePath,
                            name: "File 2.mp3",
                            size: 512,
                            contentType: "audio/mpeg",
                            isDeleted: false
                        )
                    ],
                    imageUrl: nil,
                    options: nil,
                    selectedOption: nil
                ),
                downloads: []
            ),
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: .mock(
                    name: "John Doe",
                    pictureUrl: URL.mock.absoluteString
                ),
                sender: .operator,
                content: "",
                attachment: .mock(
                    type: .files,
                    files: [
                        .mock(
                            id: fileId(),
                            url: operatorAttachmentURL,
                            name: "Screen Shot.png",
                            size: 11806,
                            contentType: "image/png",
                            isDeleted: false
                        )
                    ],
                    imageUrl: nil,
                    options: nil,
                    selectedOption: nil
                ),
                downloads: []
            ),
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: .mock(
                    name: "John Smith",
                    pictureUrl: URL.mock.appendingPathComponent("opImage").appendingPathExtension("png").absoluteString
                ),
                sender: .operator,
                content: "",
                attachment: .mock(
                    type: .files,
                    files: [
                        .mock(
                            id: fileId(),
                            url: .mock,
                            name: "File 2.pdf",
                            size: 1024,
                            contentType: "application/pdf",
                            isDeleted: false
                        )
                    ],
                    imageUrl: nil,
                    options: nil,
                    selectedOption: nil
                ),
                downloads: []
            )
        ]
        chatViewModelEnv.fetchChatHistory = { $0(.success(messages)) }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        var factoryEnv = ViewFactory.Environment.mock
        factoryEnv.data.dataWithContentsOfFileUrl = { _ in UIImage.mock.pngData() ?? Data() }
        factoryEnv.imageViewCache.getImageForKey = { _ in  .mock }
        let viewFactory = ViewFactory.mock(environment: factoryEnv)
        return .mock(chatViewModel: chatViewModel, viewFactory: viewFactory)
    }

    // MARK: - Visitor Uploaded File States
    static func mockVisitorFileUploadStates() throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        chatViewModelEnv.fetchChatHistory = { $0(.success([])) }
        var interEnv = Interactor.Environment.mock
        interEnv.coreSdk.configureWithConfiguration = { _, callback in
            callback?()
        }
        let interactor = Interactor.mock(environment: interEnv)
        let generateUUID = UUID.incrementing

        let fileUploadListModel = SecureConversations.FileUploadListViewModel.mock()

        chatViewModelEnv.createFileUploadListModel = { _ in
            fileUploadListModel
        }

        let chatViewModel = ChatViewModel.mock(interactor: interactor, environment: chatViewModelEnv)
        let controller: ChatViewController = .mock(chatViewModel: chatViewModel)
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        let localFileURL = URL.mockFilePath.appendingPathComponent("image").appendingPathExtension("png")
        var fileManager = FoundationBased.FileManager.mock
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mockFilePath] }
        fileManager.attributesOfItemAtPath = { _ in
            [FileAttributeKey.size: 12345678]
        }
        let gcd = GCD.mock
        let uiScreen = UIKitBased.UIScreen.mock
        let data = FoundationBased.Data.mock
        let date = Date.mock
        var fileUploadEnv: FileUpload.Environment = .mock
        fileUploadEnv.uuid = generateUUID
        let fileUpload: FileUpload = .mock(
            localFile: .mock(
                url: localFileURL,
                environment: .init(
                    fileManager: fileManager,
                    gcd: gcd,
                    uiScreen: uiScreen,
                    thumbnailGenerator: .mock
                )
            ),
            storage: FileSystemStorage.mock(
                directory: .documents(fileManager),
                expiration: .none,
                environment: .init(
                    fileManager: fileManager,
                    data: data,
                    date: { date }
                )
            ),
            environment: fileUploadEnv
        )
        fileUpload.state.value = .uploading(progress: .init(with: 0.5))
        fileUploadListModel.environment.uploader.uploads.append(fileUpload)

        let fileUploadComplete: FileUpload = .mock(
            localFile: .mock(
                url: localFileURL,
                environment: .init(
                    fileManager: fileManager,
                    gcd: gcd,
                    uiScreen: uiScreen,
                    thumbnailGenerator: .mock
                )
            ),
            storage: FileSystemStorage.mock(
                directory: .documents(fileManager),
                expiration: .none,
                environment: .init(
                    fileManager: fileManager,
                    data: data,
                    date: { date }
                )
            ),
            environment: fileUploadEnv
        )

        fileUploadListModel.environment.uploader.uploads.append(fileUploadComplete)
        fileUploadComplete.state.value = .uploaded(file: try .mock())

        let fileUploadWithError: FileUpload = .mock(
            localFile: .mock(
                url: localFileURL,
                environment: .init(
                    fileManager: fileManager,
                    gcd: gcd,
                    uiScreen: uiScreen,
                    thumbnailGenerator: .mock
                )
            ),
            storage: FileSystemStorage.mock(
                directory: .documents(fileManager),
                expiration: .none,
                environment: .init(
                    fileManager: fileManager,
                    data: data,
                    date: { date }
                )
            ),
            environment: fileUploadEnv
        )

        fileUploadListModel.environment.uploader.uploads.append(fileUploadWithError)
        fileUploadWithError.state.value = .error(FileUpload.Error.fileTooBig)

        chatViewModel.action?(.sendButtonHidden(false))
        chatViewModel.action?(.updateUnreadMessageIndicator(itemCount: 5))
        chatViewModel.action?(.setChoiceCardInputModeEnabled(false))
        chatViewModel.action?(.connected(name: "Mocked Operator Name", imageUrl: localFileURL.absoluteString))
        chatViewModel.action?(.setAttachmentButtonVisibility(.enabled(.enagagementConnection(isConnected: true))))
        chatViewModel.action?(.pickMediaButtonEnabled(true))
        chatViewModel.action?(.setOperatorTypingIndicatorIsHiddenTo(false, false))

        chatViewModel.action?(.fileUploadListPropsUpdated(chatViewModel.fileUploadListModel.props()))
        return controller
    }

    // MARK: - Choice Card States
    static func mockChoiceCard() throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [URL.mock] }
        chatViewModelEnv.loadChatMessagesFromHistory = { true }
        let messageUuid = UUID.incrementing
        let messageId = { messageUuid().uuidString }
        let queueId = UUID.mock.uuidString

        let options = [
            ChatChoiceCardOption(with: try .mock(text: "Four", value: "ruof")),
            ChatChoiceCardOption(with: try .mock(text: "Five", value: "evif")),
            ChatChoiceCardOption(with: try .mock(text: "One", value: "eno"))
        ]
        let messages: [ChatMessage] = [
            .mock(id: messageId(),
                  queueID: queueId,
                  operator: .mock(
                    name: "Blob",
                    pictureUrl: "https://mock.mock/operator/234/image.png"
                  ),
                  sender: .operator,
                  content: "What is 2 + 2?",
                  attachment: .init(
                    type: .singleChoice,
                    files: nil,
                    imageUrl: "https://mock.mock/single_choice/567/image.png",
                    options: options,
                    selectedOption: .some("ruof")
                  ),
                  downloads: []
                 )
        ]
        chatViewModelEnv.fetchChatHistory = { $0(.success(messages)) }

        var viewFactoryEnv = ViewFactory.Environment.mock
        viewFactoryEnv.imageViewCache.getImageForKey = { _ in UIImage.mock }

        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        let controller = ChatViewController.mock(
            chatViewModel: chatViewModel,
            viewFactory: .init(
                with: .mock(),
                messageRenderer: .mock,
                environment: viewFactoryEnv
            )
        )
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        return controller
    }

    // MARK: - Glia Virtual Assistant Persistent Button State

    static func mockGvaPersistentButton() throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [URL.mock] }
        chatViewModelEnv.loadChatMessagesFromHistory = { true }

        let messageUuid = UUID.incrementing
        let messageId = { messageUuid().uuidString }
        let queueId = UUID.mock.uuidString

        let jsonData = mockGvaPersistentButtonJson() ?? Data()
        let metadataContainer = try CoreSdkMessageMetadataContainer(jsonData: jsonData, jsonDecoder: .init())
        let metadata = Message.Metadata(container: metadataContainer.container)

        let messages: [ChatMessage] = [
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: .mock(
                    name: "Rasmus",
                    pictureUrl: "https://mock.mock/single_choice/567/image.png"
                ),
                sender: .operator,
                content: "",
                attachment: nil,
                downloads: [],
                metadata: metadata
            )
        ]

        chatViewModelEnv.fetchChatHistory = { $0(.success(messages)) }

        var viewFactoryEnv = ViewFactory.Environment.mock
        viewFactoryEnv.imageViewCache.getImageForKey = { _ in UIImage.mock }

        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        let controller = ChatViewController.mock(
            chatViewModel: chatViewModel,
            viewFactory: .init(
                with: .mock(),
                messageRenderer: .mock,
                environment: viewFactoryEnv
            )
        )
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        return controller
    }

    static func mockGvaResponseText() throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [URL.mock] }
        chatViewModelEnv.loadChatMessagesFromHistory = { true }

        let messageUuid = UUID.incrementing
        let messageId = { messageUuid().uuidString }
        let queueId = UUID.mock.uuidString

        let jsonData = mockGvaResponseTextJson() ?? Data()
        let metadataContainer = try CoreSdkMessageMetadataContainer(jsonData: jsonData, jsonDecoder: .init())
        let metadata = Message.Metadata(container: metadataContainer.container)

        let messages: [ChatMessage] = [
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: .mock(
                    name: "Rasmus",
                    pictureUrl: "https://mock.mock/single_choice/567/image.png"
                ),
                sender: .operator,
                content: "",
                attachment: nil,
                downloads: [],
                metadata: metadata
            )
        ]

        chatViewModelEnv.fetchChatHistory = { $0(.success(messages)) }

        var viewFactoryEnv = ViewFactory.Environment.mock
        viewFactoryEnv.imageViewCache.getImageForKey = { _ in UIImage.mock }

        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        let controller = ChatViewController.mock(
            chatViewModel: chatViewModel,
            viewFactory: .init(
                with: .mock(),
                messageRenderer: .mock,
                environment: viewFactoryEnv
            )
        )
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        return controller
    }

    static func mockGvaGalleryCards() throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [URL.mock] }
        chatViewModelEnv.loadChatMessagesFromHistory = { true }

        let messageUuid = UUID.incrementing
        let messageId = { messageUuid().uuidString }
        let queueId = UUID.mock.uuidString

        let jsonData = mockGvaGalleryCardJson() ?? Data()
        let metadataContainer = try CoreSdkMessageMetadataContainer(jsonData: jsonData, jsonDecoder: .init())
        let metadata = Message.Metadata(container: metadataContainer.container)

        let messages: [ChatMessage] = [
            .mock(
                id: messageId(),
                queueID: queueId,
                operator: .mock(
                    name: "Rasmus",
                    pictureUrl: "https://mock.mock/single_choice/567/image.png"
                ),
                sender: .operator,
                content: "",
                attachment: nil,
                downloads: [],
                metadata: metadata
            )
        ]

        chatViewModelEnv.fetchChatHistory = { $0(.success(messages)) }

        var viewFactoryEnv = ViewFactory.Environment.mock
        viewFactoryEnv.imageViewCache.getImageForKey = { _ in UIImage.mock }

        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        let controller = ChatViewController.mock(
            chatViewModel: chatViewModel,
            viewFactory: .init(
                with: .mock(),
                messageRenderer: .mock,
                environment: viewFactoryEnv
            )
        )
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        return controller
    }

    // MARK: - Visitor File Download States
    static func mockVisitorFileDownloadStates(completion: ([ChatMessage]) -> Void) throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        chatViewModelEnv.fetchChatHistory = { $0(.success([])) }
        let messages: [ChatMessage] =
        (0 ..< 4).map { idx in
            ChatMessage.mock(
                id: "messageId\(idx)",
                queueID: "queueId",
                operator: .mock(
                    name: "John Smith",
                    pictureUrl: URL.mock.appendingPathComponent("opImage").appendingPathExtension("png").absoluteString
                ),
                sender: .operator,
                content: "",
                attachment: .mock(
                    type: .files,
                    files: [
                        .mock(
                            id: "fileId\(idx)",
                            url: .mock,
                            name: "File \(idx).pdf",
                            size: 1024 * Double(idx),
                            contentType: "application/pdf",
                            isDeleted: false
                        )
                    ],
                    imageUrl: nil,
                    options: nil,
                    selectedOption: nil
                ),
                downloads: []
            )

        }
        chatViewModelEnv.fetchChatHistory = { $0(.success(messages)) }
        var interEnv = Interactor.Environment.mock
        interEnv.coreSdk.configureWithConfiguration = { _, callback in
            callback?()
        }
        let interactor = Interactor.mock(environment: interEnv)
        let chatViewModel = ChatViewModel.mock(interactor: interactor, environment: chatViewModelEnv)
        let controller = ChatViewController.mock(chatViewModel: chatViewModel)
        completion(messages)
        return controller
    }

    static private func mockGvaPersistentButtonJson() -> Data? {
        """
            {
                "metadata":
                {
                  "type" : "persistentButtons",
                  "content" : "This is a Glia Virutal Assistant Persistent button.",
                  "options" : [
                    {
                      "value" : "I'm first button",
                      "text" : "First Button"
                    },
                    {
                      "value" : "I'm second button",
                      "text" : "Second Button"
                    },
                    {
                      "value" : "I'm third button",
                      "text" : "Third Button"
                    }
                  ]
                }
            }
        """.data(using: .utf8)
    }

    static private func mockGvaResponseTextJson() -> Data? {
        """
            {
                "metadata":
                {
                  "type" : "plainText",
                  "content" : "This is a Glia Virutal Assistant Response Text.",
                }
            }
        """.data(using: .utf8)
    }

    static private func mockGvaGalleryCardJson() -> Data? {
        """
            {
                "metadata": {
                    "type" : "galleryCards",
                    "galleryCards" : [
                        {
                            "title" : "I'm gallery card",
                            "subtitle" : "I'm first gallery card",
                            "options" : [
                                {
                                    "value" : "I'm first button",
                                    "text" : "First Button"
                                },
                                {
                                    "value" : "I'm second button",
                                    "text" : "Second Button"
                                },
                                {
                                    "value" : "I'm third button",
                                    "text" : "Third Button"
                                }
                            ]
                        },
                        {
                            "title" : "I'm gallery card",
                            "subtitle" : "I'm second gallery card with a longer text so I will expand the view",
                            "options" : [
                                {
                                    "value" : "I'm first button",
                                    "text" : "First Button"
                                },
                                {
                                    "value" : "I'm second button",
                                    "text" : "Second Button"
                                },
                                {
                                    "value" : "I'm third button",
                                    "text" : "Third Button"
                                }
                            ]
                        }
                    ]
                }
            }
        """.data(using: .utf8)
    }
}
// swiftlint:enable function_body_length
#endif
