import SQLite3

class ChatStorage {
    struct Queue {
        let id: Int32
        let queueID: String
    }

    struct Operator {
        let id: Int32
        let name: String
        let pictureUrl: String?
    }

    struct Message {
        enum Sender: Int {
            case visitor = 0
            case `operator` = 1
        }

        let id: String
        let queueID: Int32
        let operatorID: Int32?
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

    init() {
        dbURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(kDBName)
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        guard let dbPath = dbURL?.path else { return }
        sqlite3_open(dbPath, &db)
    }

    private func createTables() {
        let queueTableSQL = """
            CREATE TABLE IF NOT EXISTS Queue(
            id INTEGER PRIMARY KEY,
            queueID TEXT NOT NULL);
        """
        let operatorTableSQL = """
            CREATE TABLE IF NOT EXISTS Operator(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            pictureUrl TEXT);
        """
        let messagesTableSQL = """
            CREATE TABLE IF NOT EXISTS Message(
            id INTEGER PRIMARY KEY,
            messageID STRING NOT NULL,
            queueID INTEGER NOT NULL,
            operatorID INTEGER,
            sender INTEGER NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY(queueID) REFERENCES Queue(id),
            FOREIGN KEY(operatorID) REFERENCES Operator(id));
        """
        execSQL(queueTableSQL)
        execSQL(operatorTableSQL)
        execSQL(messagesTableSQL)
    }

    private func execSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
}
