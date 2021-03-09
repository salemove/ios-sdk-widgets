import SalemoveSDK
import SQLite3

class ChatStorage {
    private enum RowType: Int {
        case message = 0
    }

    private enum SQLiteError: Error {
        case openDatabase
        case prepare
        case exec
    }

    private lazy var messages: [ChatMessage] = {
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

extension ChatStorage {
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
                            let object = try JSONDecoder().decode(Object.self, from: data)
                            objects.append(object)
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

extension ChatStorage {
    func messages(forQueue queueID: String) -> [ChatMessage] {
        return messages.filter({ $0.queueID == queueID })
    }

    func storeMessage(_ message: SalemoveSDK.Message,
                      queueID: String,
                      operator salemoveOperator: SalemoveSDK.Operator?) {
        let salemoveOperator = message.sender == .operator
            ? salemoveOperator
            : nil
        let message = ChatMessage(with: message, queueID: queueID, operator: salemoveOperator)
        storeMessage(message)
    }

    func storeMessages(_ messages: [SalemoveSDK.Message],
                       queueID: String,
                       operator salemoveOperator: SalemoveSDK.Operator?) {
        messages.forEach({ storeMessage($0, queueID: queueID, operator: salemoveOperator) })
    }

    func isNewMessage(_ message: SalemoveSDK.Message) -> Bool {
        return messages.first(where: { $0.id == message.id }) == nil
    }

    func newMessages(_ messages: [SalemoveSDK.Message]) -> [SalemoveSDK.Message] {
        let existingMessageIDs = messages.map({ $0.id })
        return messages.filter({ !existingMessageIDs.contains($0.id) })
    }

    private func storeMessage(_ message: ChatMessage) {
        try? storeObject(message, ofType: .message)
        messages.append(message)
    }
}
