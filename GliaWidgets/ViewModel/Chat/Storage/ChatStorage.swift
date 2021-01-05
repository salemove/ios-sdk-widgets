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
        let queueID: Int
        let operatorID: Int?
        let sender: Sender
        let content: String
        let timestamp: Int64
    }

    private var queue: Queue?
    private var `operator`: Operator?
    private var messages = [Message]()
    private var db: OpaquePointer?
    private let dbURL: URL?
    private let kDBName = "GliaChat.sqlite"
    private var lastInsertedRowID: Int64 { return sqlite3_last_insert_rowid(db) }

    init() {
        dbURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(kDBName)
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() {
        guard let dbPath = dbURL?.path else { return }
        sqlite3_open(dbPath, &db)
    }

    private func createTables() {
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
            CREATE UNIQUE INDEX index_queueid ON Queue(queueID);
        """
        execSQL(queueTableSQL)
        execSQL(operatorTableSQL)
        execSQL(messagesTableSQL)
        execSQL(queueIDIndex)
    }

    private func execSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
}

extension ChatStorage {
    func setQueue(withID queueID: String) {
        if let storedQueue = loadQueue(withID: queueID) {
            queue = storedQueue
        } else {
            queue = insertQueue(withID: queueID)
        }
    }

    private func loadQueue(withID queueID: String) -> Queue? {
        let sql = "SELECT id, queueID FROM Queue WHERE QueueID = '\(queueID)';"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let queueID = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                return Queue(id: id, queueID: queueID)
            }
        }

        sqlite3_finalize(statement)
        
        return nil
    }

    private func insertQueue(withID queueID: String) -> Queue? {
        let sql = "INSERT INTO Queue(QueueID) VALUES (?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (queueID as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                return Queue(id: lastInsertedRowID,
                             queueID: queueID)
            } else {
                return nil
            }
        }

        sqlite3_finalize(statement)

        return nil
    }
}
