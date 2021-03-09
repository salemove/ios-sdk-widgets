import SalemoveSDK
import SQLite3

class ChatStorageX {
    struct Operator: Codable {
        let name: String
        let pictureUrl: String?

        init(with salemoveOperator: SalemoveSDK.Operator) {
            name = salemoveOperator.name
            pictureUrl = salemoveOperator.picture?.url
        }
    }

    struct EngagementFile: Codable {
        let id: String?
        let url: URL?
        let name: String?
        let size: Double?

        init(with file: SalemoveSDK.EngagementFile) {
            id = file.id
            url = file.url
            name = file.name
            size = file.size
        }
    }

    enum AttachmentType: Int, Codable {
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

    struct Attachment: Codable {
        let type: AttachmentType?
        let files: [EngagementFile]?

        init(with attachment: SalemoveSDK.Attachment) {
            type = AttachmentType(with: attachment.type)
            files = attachment.files.map({ $0.map({ EngagementFile(with: $0) }) })
        }
    }

    enum MessageSender: Int, Codable {
        case visitor = 0
        case `operator` = 1
        case omniguide = 2
        case system = 3

        init(with sender: SalemoveSDK.MessageSender) {
            switch sender {
            case .visitor:
                self = .visitor
            case .operator:
                self = .operator
            case .omniguide:
                self = .omniguide
            case .system:
                self = .system
            }
        }
    }

    struct Message: Codable {
        let id: String
        let queueID: String
        let `operator`: Operator?
        let sender: MessageSender?
        let content: String
        let attachment: Attachment?

        init(with message: SalemoveSDK.Message,
             queueID: String,
             operator salemoveOperator: Operator? = nil) {
            id = message.id
            self.queueID = queueID
            self.operator = salemoveOperator
            sender = MessageSender(with: message.sender)
            content = message.content
            attachment = message.attachment.map({ Attachment(with: $0) })
        }
    }

    private enum RowType: Int {
        case message = 0
    }

    private enum SQLiteError: Error {
        case openDatabase
        case prepare
        case exec
    }

    private lazy var messages: [Message] = {
        return loadObjects(ofType: .message)
    }()
    private let encoder = JSONEncoder()
    private var db: OpaquePointer?
    private let dbURL: URL?
    private let kDBName = "GliaChat.sqlite"

    init() {
        dbURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(kDBName)

        do {
            try openDatabase()
            try createDataTable()
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

    private func createDataTable() throws {
        let createDataTable = """
            CREATE TABLE IF NOT EXISTS Data(
            ID INTEGER PRIMARY KEY NOT NULL,
            Type INTEGER NOT NULL,
            JSON TEXT NOT NULL);
        """
        let createDataTypeIndex = """
            CREATE INDEX IF NOT EXISTS index_data_type ON Data(Type);
        """

        try exec(createDataTable)
        try exec(createDataTypeIndex)
    }

    private func exec(_ sql: String, values: [Any?]? = nil, completion: (() -> Void)? = nil) throws {
        try prepare(sql) { statement in
            values?.enumerated().forEach({
                let index = Int32($0.offset + 1)
                switch $0.element {
                case nil:
                    sqlite3_bind_null(statement, index)
                case let value as Int:
                    sqlite3_bind_int(statement, index, Int32(value))
                case let value as String:
                    sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, nil)
                default:
                    print("Unsupported data type \(type(of: $0.element)) for \(String(describing: $0.element)) in exec()")
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

extension ChatStorageX {
    private func storeObject<Object: Encodable>(_ object: Object, ofType type: RowType) throws {
        let data = try encoder.encode(object)
        if let json = String(data: data, encoding: .utf8) {
            try exec("INSERT INTO Data(Type,JSON) VALUES (?,?);", values: [type.rawValue, json]) {}
        }
    }

    private func loadObjects<Object: Decodable>(ofType type: RowType) -> [Object] {
        var objects = [Object]()
        let sql = """
            SELECT JSON FROM Data WHERE Type = '\(type.rawValue)'
            ORDER BY ID;
        """
        do {
            try prepare(sql) {
                while sqlite3_step($0) == SQLITE_ROW {
                    let json = String(cString: sqlite3_column_text($0, 0))
                    if let data = json.data(using: .utf8) {
                        do {
                            objects = try JSONDecoder().decode([Object].self, from: data)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } catch {
            printLastErrorMessage()
        }
        return objects
    }
}

extension ChatStorageX {
    func storeMessage(_ message: Message) {
        try? storeObject(message, ofType: .message)
        messages.append(message)
    }

    func storeMessages(_ messages: [Message]) {
        messages.forEach({ storeMessage($0) })
    }

    func messages(forQueue queueID: String) -> [Message] {
        return messages.filter({ $0.queueID == queueID })
    }

    func isNewMessage(_ message: SalemoveSDK.Message) -> Bool {
        return !newMessages([message]).isEmpty
    }

    func newMessages(_ messages: [SalemoveSDK.Message]) -> [SalemoveSDK.Message] {
        let existingMessageIDs = messages.map({ $0.id })
        return messages.filter({ !existingMessageIDs.contains($0.id) })
    }
}
