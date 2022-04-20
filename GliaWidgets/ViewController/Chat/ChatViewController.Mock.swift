#if DEBUG
import Foundation
import UIKit

// swiftlint:disable function_body_length
extension ChatViewController {
    static func mock(
        chatViewModel: ChatViewModel = .mock(),
        viewFactory: ViewFactory = .mock()
    ) -> ChatViewController {
        ChatViewController(
            viewModel: chatViewModel,
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
        chatViewModelEnv.chatStorage.isEmpty = { true }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        return .mock(chatViewModel: chatViewModel)
    }

    // MARK: - Messages from Chat Storage
    static func mockHistoryMessagesScreen() -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        var fileManager = FoundationBased.FileManager.mock
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        chatViewModelEnv.fileManager = fileManager
        chatViewModelEnv.uiImage.imageWithContentsOfFileAtPath = { _ in .mock }
        let createFileDownload = chatViewModelEnv.createFileDownload
        chatViewModelEnv.createFileDownload = { file, storage, env in
            let fileDownload = createFileDownload(file, storage, env)
            var localFileEnv = LocalFile.Environment.mock
            localFileEnv.localFileThumbnailQueue.addOperation = { $0() }
            localFileEnv.gcd.globalQueue = .init(async: { $0() })
            localFileEnv.gcd.mainQueue = .init(async: { $0() }, asyncIfNeeded: { $0() })
            localFileEnv.uiImage.imageWithContentsOfFileAtPath = { _ in .mock }
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
        chatViewModelEnv.chatStorage.messages = { _ in
            [
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
        }
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
        chatViewModelEnv.chatStorage.isEmpty = { true }
        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        let controller: ChatViewController = .mock(chatViewModel: chatViewModel)
        controller.view.frame = UIScreen.main.bounds
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        let localFileURL = URL.mockFilePath.appendingPathComponent("image").appendingPathExtension("png")
        var fileManager = FoundationBased.FileManager.mock
        fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mockFilePath] }
        fileManager.attributesOfItemAtPath = { _ in
            [FileAttributeKey.size: 12345678]
        }
        let gcd = GCD.mock
        let localFileThumbnailQueue = FoundationBased.OperationQueue.mock()
        let uiImage = UIKitBased.UIImage.mock
        let data = FoundationBased.Data.mock
        let date = Date.mock
        let fileUploadEnv: FileUpload.Environment = .mock
        let fileUpload: FileUpload = .mock(
            localFile: .mock(
                url: localFileURL,
                environment: .init(
                    fileManager: fileManager,
                    gcd: gcd,
                    localFileThumbnailQueue: localFileThumbnailQueue,
                    uiImage: uiImage
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
        chatViewModel.action?(
            .addUpload(fileUpload)
        )
        fileUpload.state.value = .uploading(progress: .init(with: 0.5))

        let fileUploadComplete: FileUpload = .mock(
            localFile: .mock(
                url: localFileURL,
                environment: .init(
                    fileManager: fileManager,
                    gcd: gcd,
                    localFileThumbnailQueue: localFileThumbnailQueue,
                    uiImage: uiImage
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
        chatViewModel.action?(
            .addUpload(fileUploadComplete)
        )

        fileUploadComplete.state.value = .uploaded(file: try .mock())

        let fileUploadWithError: FileUpload = .mock(
            localFile: .mock(
                url: localFileURL,
                environment: .init(
                    fileManager: fileManager,
                    gcd: gcd,
                    localFileThumbnailQueue: localFileThumbnailQueue,
                    uiImage: uiImage
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
        chatViewModel.action?(
            .addUpload(fileUploadWithError)
        )

        fileUploadWithError.state.value = .error(FileUpload.Error.fileTooBig)

        chatViewModel.action?(.sendButtonHidden(false))
        chatViewModel.action?(.updateUnreadMessageIndicator(itemCount: 5))
        chatViewModel.action?(.connected(name: "Mocked Operator Name", imageUrl: localFileURL.absoluteString))
        chatViewModel.action?(.pickMediaButtonEnabled(true))
        chatViewModel.action?(.setOperatorTypingIndicatorIsHiddenTo(false, false))

        return controller
    }

    // MARK: - Choice Card States
    static func mockChoiceCard() throws -> ChatViewController {
        var chatViewModelEnv = ChatViewModel.Environment.mock
        chatViewModelEnv.fileManager.urlsForDirectoryInDomainMask = { _, _ in [.mock] }
        chatViewModelEnv.fromHistory = {
            true
        }
        let messageUuid = UUID.incrementing
        let messageId = { messageUuid().uuidString }
        let queueId = UUID.mock.uuidString

        let options = [
            ChatChoiceCardOption(with: try .mock(text: "Four", value: "ruof")),
            ChatChoiceCardOption(with: try .mock(text: "Five", value: "evif")),
            ChatChoiceCardOption(with: try .mock(text: "One", value: "eno"))
        ]

        chatViewModelEnv.chatStorage.messages = { _ in
            [
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
        }

        var viewFactoryEnv = ViewFactory.Environment.mock
        viewFactoryEnv.imageViewCache.getImageForKey = { _ in .mock }

        let chatViewModel = ChatViewModel.mock(environment: chatViewModelEnv)
        let controller: ChatViewController = .mock(
            chatViewModel: chatViewModel,
            viewFactory: .init(
                with: .mock(),
                environment: viewFactoryEnv
            )
        )
        controller.view.frame = UIScreen.main.bounds
        chatViewModel.action?(.setMessageText("Input Message Mock"))
        return controller
    }
}
// swiftlint:enable function_body_length
#endif
