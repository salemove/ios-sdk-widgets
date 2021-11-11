import SalemoveSDK
import SQLite3

class ChatStorage {

    static let dbName = "GliaChat.sqlite"
    static let dbUrl = try? FileManager.default
        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(dbName)

    private enum SQLiteError: Error {
        case openDatabase
        case prepare
        case exec
    }

    private lazy var messages: [ChatMessage] = {
        return loadMessages()
    }()

    private let encoder = JSONEncoder()
    private var db: OpaquePointer?

    init() {

        do {
            try openDatabase()
            try createMessagesTable()
        } catch {
            printLastErrorMessage()
        }
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() throws {
        guard let dbPath = Self.dbUrl?.path else { return }
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            throw SQLiteError.openDatabase
        }
    }

    private func createMessagesTable() throws {
        let createMessageTable = """
            CREATE TABLE IF NOT EXISTS Message(
            ID INTEGER PRIMARY KEY NOT NULL,
            MessageID TEXT NOT NULL,
            JSON TEXT NOT NULL);
        """
        let createMessageIDIndex = """
            CREATE UNIQUE INDEX IF NOT EXISTS index_message_messageid ON Message(MessageID);
        """

        try exec(createMessageTable)
        try exec(createMessageIDIndex)
    }

    private func exec(_ sql: String, values: [Any?]? = nil, completion: (() -> Void)? = nil) throws {
        try prepare(sql) { statement in
            values?.enumerated().forEach {
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
            }

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
        let lastErrorMessage = sqlite3_errmsg(db).map { String(cString: $0) } ?? "UNKNOWN DB ERROR"
        print(lastErrorMessage)
        #endif
    }
}

extension ChatStorage {
    private func storeMessage(_ message: ChatMessage) throws {
        let data = try encoder.encode(message)
        if let json = String(data: data, encoding: .utf8) {
            try exec("INSERT INTO Message(MessageID, JSON) VALUES (?, ?);", values: [message.id, json]) {}
        }
    }

    private func replaceMessage(_ message: ChatMessage) throws {
        let data = try encoder.encode(message)
        if let json = String(data: data, encoding: .utf8) {
            try exec("REPLACE INTO Message(MessageID, JSON) VALUES (?, ?);", values: [message.id, json]) {}
        }
    }

    private func loadMessages() -> [ChatMessage] {
        var messages = [ChatMessage]()
        let sql = """
            SELECT JSON FROM Message
            ORDER BY ID;
        """

        do {
            try prepare(sql) {
                while sqlite3_step($0) == SQLITE_ROW {
                    let json = String(cString: sqlite3_column_text($0, 0))

                    if let data = json.data(using: .utf8) {
                        do {
                            let message = try JSONDecoder().decode(ChatMessage.self, from: data)
                            messages.append(message)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } catch {
            printLastErrorMessage()
        }
        return messages
    }
}

extension ChatStorage {
    func isEmpty() -> Bool {
        return messages.isEmpty
    }

    func messages(forQueue queueID: String) -> [ChatMessage] {
        return messages.filter { $0.queueID == queueID }
    }

    func updateMessage(_ message: ChatMessage) {
        try? replaceMessage(message)

        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[index] = message
    }

    func storeMessage(
        _ message: SalemoveSDK.Message,
        queueID: String,
        operator salemoveOperator: SalemoveSDK.Operator?
    ) {
        let salemoveOperator = message.sender == .operator
            ? salemoveOperator
            : nil
        let message = ChatMessage(with: message, queueID: queueID, operator: salemoveOperator)
        try? storeMessage(message)
        messages.append(message)
    }

    func storeMessages(
        _ messages: [SalemoveSDK.Message],
        queueID: String,
        operator salemoveOperator: SalemoveSDK.Operator?
    ) {
        messages.forEach { storeMessage($0, queueID: queueID, operator: salemoveOperator) }
    }

    func isNewMessage(_ message: SalemoveSDK.Message) -> Bool {
        return messages.first(where: { $0.id == message.id }) == nil
    }

    func newMessages(_ messages: [SalemoveSDK.Message]) -> [SalemoveSDK.Message] {
        let existingMessageIDs = messages.map { $0.id }
        return messages.filter { !existingMessageIDs.contains($0.id) }
    }
}
