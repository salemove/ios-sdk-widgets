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

    private enum Result {
        case success(OpaquePointer?)
        case failure
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
        exec(queueTableSQL)
        exec(operatorTableSQL)
        exec(messagesTableSQL)
        exec(queueIDIndex)
    }

    private func exec(_ sql: String) {
        prepare(sql) {
            switch $0 {
            case .success(let statement):
                sqlite3_step(statement)
            case .failure:
                break
            }
        }
    }

    private func insert(_ sql: String, values: [Any], completion: (Result) -> Void) {
        prepare(sql) {
            switch $0 {
            case .success(let statement):
                values.enumerated().forEach({
                    let index = Int32($0.offset + 1)
                    switch $0.element {
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
                    completion(.success(statement))
                } else {
                    completion(.failure)
                }
            case .failure:
                break
            }
        }
    }

    private func prepare(_ sql: String, completion: (Result) -> Void) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            completion(.success(statement))
        } else {
            completion(.failure)
        }
        sqlite3_finalize(statement)
    }
}

extension ChatStorage {
    func setQueue(withID queueID: String) {
        loadQueue(withID: queueID) { queue in
            if let queue = queue {
                self.queue = queue
            } else {
                insertQueue(withID: queueID) { queue in
                    self.queue = queue
                }
            }
        }
    }

    private func loadQueue(withID queueID: String, completion: (Queue?) -> Void) {
        prepare("SELECT id, queueID FROM Queue WHERE QueueID = '\(queueID)';") {
            switch $0 {
            case .success(let statement):
                if sqlite3_step(statement) == SQLITE_ROW {
                    let id = sqlite3_column_int64(statement, 0)
                    let queueID = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                    let queue = Queue(id: id, queueID: queueID)
                    completion(queue)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }

    private func insertQueue(withID queueID: String, completion: (Queue?) -> Void) {
        insert("INSERT INTO Queue(QueueID) VALUES (?);",
               values: [queueID]) {
            switch $0 {
            case .success:
                let queue = Queue(id: lastInsertedRowID,
                                  queueID: queueID)
                completion(queue)
            case .failure:
                completion(nil)
            }
        }
    }
}
