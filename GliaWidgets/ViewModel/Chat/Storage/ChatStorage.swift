import SalemoveSDK
import SQLite3

class ChatStorage {
    struct Queue {
        let id: Int64
        let queueID: String
    }

    struct Operator {
        let id: Int64
        let name: String
        let pictureUrl: String?
    }

    struct EngagementFile {
        let id: Int64
        let fileID: String?
        let url: URL?
        let name: String?
        let size: Double?
    }

    enum AttachmentType: Int {
        case unknown = 0
        case files = 1
        case singleChoice = 2
        case singleChoiceResponse = 3

        init?(with type: SalemoveSDK.AttachmentType?) {
            switch type {
            case .files:
                self = .files
            case .singleChoice:
                self = .singleChoice
            case .singleChoiceResponse:
                self = .singleChoiceResponse
            case nil:
                return nil
            }
        }
    }

    struct Attachment {
        let id: Int64
        let type: AttachmentType
        let files: [EngagementFile]?
    }

    struct Message {
        let id: String
        let operatorID: Int64?
        let sender: MessageSender
        let content: String
        let attachment: Attachment?
    }

    private enum SQLiteError: Error {
        case openDatabase
        case prepare
        case exec
    }

    private var queue: Queue?
    private var currentOperator: Operator?
    private var messages = [Message]()
    private var operatorCache = [Int64: Operator]()
    private var db: OpaquePointer?
    private let dbURL: URL?
    private let kDBName = "GliaChat.sqlite"
    private let kDBSchemaVersion: Int64 = 1
    private var lastInsertedRowID: Int64 { return sqlite3_last_insert_rowid(db) }

    init() {
        dbURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(kDBName)

        do {
            try openDatabase()
            try createTables()
            try migrateIfNeeded()
        } catch {
            printLastErrorMessage()
        }
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() throws {
        guard let dbPath = dbURL?.path else { return }

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            throw SQLiteError.openDatabase
        }
    }

    private func createTables() throws {
        try exec(dbSchemaTableSQL)
        try exec(queueTableSQL)
        try exec(operatorTableSQL)
        try exec(engagementFileTableSQL)
        try exec(attachmentTableSQL)
        try exec(attachmentFileTableSQL)
        try exec(messageTableSQL)
        try exec(queueIDIndex)
        try exec(operatorNamePictureIndex)
        try exec(messageIDIndex)
    }

    private func exec(_ sql: String, values: [Any?]? = nil, completion: (() -> Void)? = nil) throws {
        try prepare(sql) { statement in
            values?.enumerated().forEach({
                let index = Int32($0.offset + 1)
                switch $0.element {
                case nil:
                    sqlite3_bind_null(statement, index)
                case let value as Int32:
                    sqlite3_bind_int(statement, index, value)
                case let value as Int64:
                    sqlite3_bind_int64(statement, index, value)
                case let value as String:
                    sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, nil)
                default:
                    break
                }
            })

            if sqlite3_step(statement) == SQLITE_DONE {
                completion?()
            } else {
                throw SQLiteError.exec
            }
        }
    }

    private func prepare(_ sql: String, work: (OpaquePointer) throws -> Void) throws {
        var statement: OpaquePointer?

        defer {
            sqlite3_finalize(statement)
        }

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement = statement {
            try work(statement)
        } else {
            throw SQLiteError.prepare
        }
    }

    private func printLastErrorMessage() {
        #if DEBUG
        let lastErrorMessage = sqlite3_errmsg(db).map({ String(cString: $0) }) ?? "UNKNOWN DB ERROR"
        print(lastErrorMessage)
        #endif
    }
}

extension ChatStorage {
    private func migrateIfNeeded() throws {
        try loadDBSchemaVersion { [self] version in
            if let version = version {
                if version < self.kDBSchemaVersion {
                    try self.migrate(fromVersion: version, toVersion: self.kDBSchemaVersion)
                }
            } else {
                try self.insertDBSchemaVersion(self.kDBSchemaVersion)
            }
        }
    }

    private func migrate(fromVersion: Int64, toVersion: Int64) throws {
        // do any migration actions here
        try updateDBSchemaVersion(to: toVersion)
    }
}

extension ChatStorage {
    private func loadDBSchemaVersion(completion: @escaping (Int64?) throws -> Void) throws {
        try prepare("SELECT Version FROM DBSchema;") {
            if sqlite3_step($0) == SQLITE_ROW {
                let version = sqlite3_column_int64($0, 0)
                try completion(version)
            }
        }
    }

    private func insertDBSchemaVersion(_ version: Int64) throws {
        try exec("INSERT INTO DBSchema(Version) VALUES (?);", values: [version]) {}
    }

    private func updateDBSchemaVersion(to version: Int64) throws {
        try exec("UPDATE DBSchema SET Version = ?;", values: [version]) {}
    }
}

extension ChatStorage {
    func setQueue(withID queueID: String) {
        do {
            try loadQueue(withID: queueID) { queue in
                if let queue = queue {
                    self.queue = queue
                } else {
                    try storeQueue(withID: queueID) { queue in
                        self.queue = queue
                    }
                }
            }
        } catch {
            printLastErrorMessage()
        }
    }

    private func loadQueue(withID queueID: String, completion: (Queue?) throws -> Void) throws {
        try prepare("SELECT ID, QueueID FROM Queue WHERE QueueID = '\(queueID)';") {
            if sqlite3_step($0) == SQLITE_ROW {
                let id = sqlite3_column_int64($0, 0)
                let queueID = String(cString: sqlite3_column_text($0, 1))
                let queue = Queue(id: id, queueID: queueID)
                try completion(queue)
            } else {
                try completion(nil)
            }
        }
    }

    private func storeQueue(withID queueID: String, completion: @escaping (Queue?) -> Void) throws {
        try exec("INSERT INTO Queue(QueueID) VALUES (?);", values: [queueID]) {
            completion(Queue(id: self.lastInsertedRowID,
                             queueID: queueID))
        }
    }
}

extension ChatStorage {
    func setOperator(name: String, pictureUrl: String?) {
        do {
            try loadOperator(withID: name, pictureUrl: pictureUrl, completion: { storedOperator in
                if let storedOperator = storedOperator {
                    self.currentOperator = storedOperator
                } else {
                    try storeOperator(name: name, pictureUrl: pictureUrl) {
                        self.currentOperator = $0
                    }
                }
            })
        } catch {
            printLastErrorMessage()
        }
    }

    func storedOperator(withID id: Int64) -> Operator? {
        if let storedOperator = operatorCache[id] {
            return storedOperator
        } else {
            do {
                try prepare("SELECT ID, Name, PictureUrl FROM Operator WHERE ID = '\(id)';") {
                    if sqlite3_step($0) == SQLITE_ROW {
                        let id = sqlite3_column_int64($0, 0)
                        let name = String(cString: sqlite3_column_text($0, 1))
                        let pictureUrl = sqlite3_column_text($0, 1).map({ String(cString: $0) })
                        operatorCache[id] = Operator(id: id, name: name, pictureUrl: pictureUrl)
                    }
                }
            } catch {
                printLastErrorMessage()
            }

            return operatorCache[id]
        }
    }

    private func loadOperator(withID name: String, pictureUrl: String?, completion: (Operator?) throws -> Void) throws {
        let pictureUrlSQL: String = {
            if let pictureUrl = pictureUrl {
                return "PictureUrl = '\(pictureUrl)'"
            } else {
                return "PictureUrl IS NULL"
            }
        }()
        try prepare("SELECT ID, Name, PictureUrl FROM Operator WHERE Name = '\(name)' AND \(pictureUrlSQL);") {
            if sqlite3_step($0) == SQLITE_ROW {
                let id = sqlite3_column_int64($0, 0)
                let name = String(cString: sqlite3_column_text($0, 1))
                let pictureUrl = sqlite3_column_text($0, 2).map({ String(cString: $0) })
                let storedOperator = Operator(
                    id: id,
                    name: name,
                    pictureUrl: pictureUrl
                )
                try completion(storedOperator)
            } else {
                try completion(nil)
            }
        }
    }

    private func storeOperator(name: String, pictureUrl: String?, completion: @escaping (Operator?) -> Void) throws {
        try exec("INSERT INTO Operator(Name, PictureUrl) VALUES (?,?);", values: [name, pictureUrl]) {
            completion(Operator(id: self.lastInsertedRowID,
                                name: name,
                                pictureUrl: pictureUrl))
        }
    }
}

extension ChatStorage {
    private func engagementFiles(forAttachment attachmentID: Int64) -> [EngagementFile] {
        var files = [EngagementFile]()
        do {
            let sql = """
            SELECT ID, EngagementFileID, Url, Name, Size
            FROM EngagementFile JOIN AttachmentFile ON EngagementFile.ID = AttachmentFile.AttachmentID
            WHERE AttachmentFile.AttachmentID = '\(attachmentID)'
            ORDER BY EngagementFileID;
            """
            try prepare(sql) {
                while sqlite3_step($0) == SQLITE_ROW {
                    let id = sqlite3_column_int64($0, 0)
                    let fileID = String(cString: sqlite3_column_text($0, 1))
                    let urlString = String(cString: sqlite3_column_text($0, 2))
                    let name = String(cString: sqlite3_column_text($0, 3))
                    let size = sqlite3_column_double($0, 4)
                    let file = EngagementFile(
                        id: id,
                        fileID: fileID,
                        url: URL(string: urlString),
                        name: name,
                        size: size
                    )
                    files.append(file)
                }
            }
        } catch {
            printLastErrorMessage()
        }
        return files
    }

    private func storeEngagementFile(_ file: SalemoveSDK.EngagementFile, completion: @escaping (EngagementFile) -> Void) throws {
        try exec("INSERT INTO EngagementFile(Url, Name, Size) VALUES (?,?,?);", values: [file.url, file.name, file.size]) {
            completion(EngagementFile(id: self.lastInsertedRowID,
                                      fileID: file.id,
                                      url: file.url,
                                      name: file.name,
                                      size: file.size))
        }
    }

    private func storeEngagementFiles(_ files: [SalemoveSDK.EngagementFile], completion: @escaping ([EngagementFile]) -> Void) throws {
        var engagementFiles = [EngagementFile]()
        try files.forEach { file in
            try storeEngagementFile(file) { file in
                engagementFiles.append(file)
            }
        }
        completion(engagementFiles)
    }
}

extension ChatStorage {
    private func attachment(withID id: Int64) -> Attachment? {
        var attachment: Attachment?
        do {
            try prepare("SELECT ID, Type FROM Attachment WHERE ID = '\(id)';") {
                if sqlite3_step($0) == SQLITE_ROW {
                    let id = sqlite3_column_int64($0, 0)
                    let rawType = Int(sqlite3_column_int64($0, 1))
                    let type = AttachmentType(rawValue: rawType) ?? .unknown
                    let files = engagementFiles(forAttachment: id)
                    attachment = Attachment(id: id, type: type, files: files)
                }
            }
        } catch {
            printLastErrorMessage()
        }
        return attachment
    }

    private func storeAttachment(_ attachment: SalemoveSDK.Attachment, completion: @escaping (Attachment) -> Void) throws {
        var attachmentID: Int64?
        var engagementFiles: [EngagementFile]?
        let type = AttachmentType(with: attachment.type)
        try exec("INSERT INTO Attachment(Type) VALUES (?);", values: [type]) {
            attachmentID = self.lastInsertedRowID
        }
        try storeEngagementFiles(attachment.files ?? [], completion: { files in
            engagementFiles = files
        })
        try engagementFiles?.forEach { file in
            try self.exec("INSERT INTO AttachmentFile(AttachmentID, EngagementFileID) VALUES (?,?);",
                          values: [attachmentID, file.id]) {}
        }
        try attachment.files?.forEach({ file in
            try self.storeEngagementFile(file) { file in
                do {
                    try self.exec("INSERT INTO AttachmentFile(AttachmentID, EngagementFileID) VALUES (?,?);",
                                  values: [attachmentID, file.id]) {}
                } catch {
                    self.printLastErrorMessage()
                }
            }
        })
    }
}

extension ChatStorage {
    func storeMessage(_ message: SalemoveSDK.Message) {
        guard let queueID = queue?.id else { return }

        let operatorID = message.sender == .operator
            ? currentOperator?.id
            : nil
        let timestamp = Int64(NSDate().timeIntervalSince1970)
        var attachmentID: Int64?

        do {
            if let attachment = message.attachment {
                try storeAttachment(attachment, completion: { attachment in
                    attachmentID = attachment.id
                })
            }
            try exec("INSERT INTO Message(MessageID, QueueID, OperatorID, Sender, Content, AttachmentID, Timestamp) VALUES (?,?,?,?,?,?,?);",
                     values: [message.id, queueID, operatorID, message.sender.stringValue, message.content, attachmentID, timestamp]) {}
        } catch {
            printLastErrorMessage()
        }
    }

    func storeMessages(_ messages: [SalemoveSDK.Message]) {
        messages.forEach({ storeMessage($0) })
    }

    func messages(forQueue queueID: String) -> [Message] {
        var messages = [Message]()
        do {
            let sql = """
            SELECT MessageID, OperatorID, Content, Sender, AttachmentID
            FROM Message JOIN Queue ON Message.QueueID = Queue.ID
            WHERE Queue.QueueID = '\(queueID)'
            ORDER BY Message.Timestamp;
            """
            try prepare(sql) {
                while sqlite3_step($0) == SQLITE_ROW {
                    let id = String(cString: sqlite3_column_text($0, 0))
                    let operatorID = sqlite3_column_int64($0, 1)
                    let content = String(cString: sqlite3_column_text($0, 2))
                    guard let sender = MessageSender(stringValue: String(cString: sqlite3_column_text($0, 3))) else { continue }
                    let attachmentID = sqlite3_column_int64($0, 4)
                    let attachment = self.attachment(withID: attachmentID)
                    let message = Message(
                        id: id,
                        operatorID: operatorID,
                        sender: sender,
                        content: content,
                        attachment: attachment
                    )
                    messages.append(message)
                }
            }
        } catch {
            printLastErrorMessage()
        }
        return messages
    }

    func isNewMessage(_ message: SalemoveSDK.Message) -> Bool {
        return !newMessages([message]).isEmpty
    }

    func newMessages(_ messages: [SalemoveSDK.Message]) -> [SalemoveSDK.Message] {
        let messageIDs = Set<String>(messages.map({ $0.id }))
        var existingMessageIDs = Set<String>()

        do {
            let ids = messageIDs.map({ "'\($0)'" }).joined(separator: ",")
            try prepare("SELECT MessageID FROM Message WHERE MessageID IN (\(ids))") {
                while sqlite3_step($0) == SQLITE_ROW {
                    let id = String(cString: sqlite3_column_text($0, 0))
                    existingMessageIDs.insert(id)
                }
            }
        } catch {
            printLastErrorMessage()
        }

        let newMessageIDs = messageIDs.subtracting(existingMessageIDs)

        return messages.filter({ newMessageIDs.contains($0.id) })
    }
}
