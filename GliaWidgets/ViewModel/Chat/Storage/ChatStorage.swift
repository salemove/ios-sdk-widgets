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

    struct Message {
        let messageID: String
        let operatorID: Int64?
        let sender: MessageSender
        let content: String
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
    private var lastInsertedRowID: Int64 { return sqlite3_last_insert_rowid(db) }
    private var lastErrorMessage: String { return sqlite3_errmsg(db).map({ String(cString: $0) }) ?? "UNKNOWN" }

    init() {
        dbURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(kDBName)
        print(dbURL?.path)
        do {
            try openDatabase()
            try createTables()
        } catch {
            print("\(#function): \(lastErrorMessage)")
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
        let queueTableSQL = """
            CREATE TABLE IF NOT EXISTS Queue(
            id INTEGER PRIMARY KEY NOT NULL,
            queueID TEXT NOT NULL);
        """
        let operatorTableSQL = """
            CREATE TABLE IF NOT EXISTS Operator(
            id INTEGER PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            pictureUrl TEXT);
        """
        let messagesTableSQL = """
            CREATE TABLE IF NOT EXISTS Message(
            id INTEGER PRIMARY KEY NOT NULL,
            messageID STRING NOT NULL,
            queueID INTEGER NOT NULL,
            operatorID INTEGER,
            sender TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY(queueID) REFERENCES Queue(id),
            FOREIGN KEY(operatorID) REFERENCES Operator(id));
        """
        let queueIDIndex = """
            CREATE UNIQUE INDEX IF NOT EXISTS index_queueid ON Queue(queueID);
        """
        let operatorNamePictureIndex = """
            CREATE UNIQUE INDEX IF NOT EXISTS index_operator_name ON Operator(name, pictureUrl);
        """
        let messageIDIndex = """
            CREATE UNIQUE INDEX IF NOT EXISTS index_messages_messageID ON Message(messageID);
        """

        try exec(queueTableSQL)
        try exec(operatorTableSQL)
        try exec(messagesTableSQL)
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
}

extension ChatStorage {
    func setQueue(withID queueID: String) {
        do {
            try loadQueue(withID: queueID) { queue in
                if let queue = queue {
                    self.queue = queue
                } else {
                    try insertQueue(withID: queueID) { queue in
                        self.queue = queue
                    }
                }
            }
        } catch {
            print("\(#function): \(lastErrorMessage)")
        }
    }

    private func loadQueue(withID queueID: String, completion: (Queue?) throws -> Void) throws {
        try prepare("SELECT id, queueID FROM Queue WHERE queueID = '\(queueID)';") {
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

    private func insertQueue(withID queueID: String, completion: @escaping (Queue?) -> Void) throws {
        try exec("INSERT INTO Queue(queueID) VALUES (?);", values: [queueID]) {
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
                    try insertOperator(name: name, pictureUrl: pictureUrl) {
                        self.currentOperator = $0
                    }
                }
            })
        } catch {
            print("\(#function): \(lastErrorMessage)")
        }
    }

    func storedOperator(withID id: Int64) -> Operator? {
        if let storedOperator = operatorCache[id] {
            return storedOperator
        } else {
            do {
                try prepare("SELECT id, name, pictureUrl FROM Operator WHERE id = '\(id)';") {
                    if sqlite3_step($0) == SQLITE_ROW {
                        let id = sqlite3_column_int64($0, 0)
                        let name = String(cString: sqlite3_column_text($0, 1))
                        let pictureUrl = sqlite3_column_text($0, 1).map({ String(cString: $0) })
                        operatorCache[id] = Operator(id: id, name: name, pictureUrl: pictureUrl)
                    }
                }
            } catch {
                print("\(#function): \(lastErrorMessage)")
            }

            return operatorCache[id]
        }
    }

    private func loadOperator(withID name: String, pictureUrl: String?, completion: (Operator?) throws -> Void) throws {
        let pictureUrlSQL: String = {
            if let pictureUrl = pictureUrl {
                return "pictureUrl = '\(pictureUrl)'"
            } else {
                return "pictureUrl IS NULL"
            }
        }()
        try prepare("SELECT id, name, pictureUrl FROM Operator WHERE name = '\(name)' AND \(pictureUrlSQL);") {
            if sqlite3_step($0) == SQLITE_ROW {
                let id = sqlite3_column_int64($0, 0)
                let name = String(cString: sqlite3_column_text($0, 1))
                let pictureUrl = sqlite3_column_text($0, 2).map({ String(cString: $0) })
                let storedOperator = Operator(id: id,
                                              name: name,
                                              pictureUrl: pictureUrl)
                try completion(storedOperator)
            } else {
                try completion(nil)
            }
        }
    }

    private func insertOperator(name: String, pictureUrl: String?, completion: @escaping (Operator?) -> Void) throws {
        try exec("INSERT INTO Operator(name, pictureUrl) VALUES (?,?);", values: [name, pictureUrl]) {
            completion(Operator(id: self.lastInsertedRowID,
                                name: name,
                                pictureUrl: pictureUrl))
        }
    }
}

extension ChatStorage {
    func storeMessage(_ message: SalemoveSDK.Message) {
        guard let queueID = queue?.id else { return }

        let operatorID = message.sender == .operator
            ? currentOperator?.id
            : nil
        let timestamp = Int64(NSDate().timeIntervalSince1970)

        do {
            try exec("INSERT INTO Message(messageID, queueID, operatorID, sender, content, timestamp) VALUES (?,?,?,?,?,?);",
                     values: [message.id, queueID, operatorID, message.sender.stringValue, message.content, timestamp]) {}
        } catch {
            print("\(#function): \(lastErrorMessage)")
        }
    }

    func messages(forQueue queueID: String) -> [Message] {
        var messages = [Message]()

        do {
            let sql = """
            SELECT messageID, operatorID, content, sender
            FROM Message JOIN Queue ON Message.queueID = Queue.id
            WHERE Queue.queueID = '\(queueID)'
            ORDER BY Message.id;
            """
            try prepare(sql) {
                while sqlite3_step($0) == SQLITE_ROW {
                    let messageID = String(cString: sqlite3_column_text($0, 0))
                    let operatorID = sqlite3_column_int64($0, 1)
                    let content = String(cString: sqlite3_column_text($0, 2))
                    guard let sender = MessageSender(stringValue: String(cString: sqlite3_column_text($0, 3))) else { continue }
                    let message = Message(messageID: messageID,
                                          operatorID: operatorID,
                                          sender: sender,
                                          content: content)
                    messages.append(message)
                }
            }
        } catch {
            print("\(#function): \(lastErrorMessage)")
        }

        return messages
    }
}
