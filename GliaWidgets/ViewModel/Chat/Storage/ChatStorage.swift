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
        enum Sender: Int {
            case visitor = 0
            case `operator` = 1
        }

        let id: Int64
        let messageID: String
        let queueID: Int64
        let operatorID: Int64?
        let sender: Sender
        let content: String
        let timestamp: Int64
    }

    private enum SQLiteError: Error {
        case openDatabase
        case prepare
        case insert
    }

    var storedMessages: [Message] { return messages }

    private var queue: Queue? {
        didSet { loadMessages() }
    }
    private var `operator`: Operator?
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
            sender INTEGER NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY(queueID) REFERENCES Queue(id),
            FOREIGN KEY(operatorID) REFERENCES Operator(id));
        """
        let queueIDIndex = """
            CREATE UNIQUE INDEX IF NOT EXISTS index_queueid ON Queue(queueID);
        """

        try exec(queueTableSQL)
        try exec(operatorTableSQL)
        try exec(messagesTableSQL)
        try exec(queueIDIndex)
    }

    private func exec(_ sql: String, completion: (() -> Void)? = nil) throws {
        try prepare(sql) {
            sqlite3_step($0)
            completion?()
        }
    }

    private func insert(_ sql: String, values: [Any?], completion: () -> Void) throws {
        try prepare(sql) { statement in
            values.enumerated().forEach({
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
                completion()
            } else {
                throw SQLiteError.insert
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

    private func insertQueue(withID queueID: String, completion: (Queue?) -> Void) throws {
        try insert("INSERT INTO Queue(queueID) VALUES (?);", values: [queueID]) {
            completion(Queue(id: lastInsertedRowID,
                             queueID: queueID))
        }
    }
}

extension ChatStorage {
    func setOperator(name: String, pictureUrl: String?) {
        do {
            try insertOperator(name: name, pictureUrl: pictureUrl) {
                self.operator = $0
            }
        } catch {
            print("\(#function): \(lastErrorMessage)")
        }
    }

    func storedOperator(withID id: Int64) -> Operator? {
        if let storedOperator = operatorCache[id] {
            return storedOperator
        } else {
            var storedOperator: Operator?
            do {
                try prepare("SELECT id, name, pictureUrl FROM Operator WHERE id = '\(id)';") {
                    if sqlite3_step($0) == SQLITE_ROW {
                        let id = sqlite3_column_int64($0, 0)
                        let name = String(cString: sqlite3_column_text($0, 1))
                        let pictureUrl = sqlite3_column_text($0, 1).map({ String(cString: $0) })
                        storedOperator = Operator(id: id, name: name, pictureUrl: pictureUrl)
                    }
                }
            } catch {
                print("\(#function): \(lastErrorMessage)")
            }

            return storedOperator
        }
    }

    private func insertOperator(name: String, pictureUrl: String?, completion: (Operator?) -> Void) throws {
        try insert("INSERT INTO Operator(name, pictureUrl) VALUES (?,?);", values: [name, pictureUrl]) {
            completion(Operator(id: lastInsertedRowID,
                                name: name,
                                pictureUrl: pictureUrl))
        }
    }
}

extension ChatStorage {
    func storeMessage(id: String, content: String, sender: Message.Sender) {
        // TODO
    }

    func messages(forQueue queueID: String) -> [Message] {
        return [] // TODO
    }

    private func loadMessages() {
        guard let queue = queue else {
            messages = []
            return
        }

    }
}
