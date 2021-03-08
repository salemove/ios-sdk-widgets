extension ChatStorage {
    var dbSchemaTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS DBSchema(
            ID INTEGER PRIMARY KEY NOT NULL,
            Version INTEGER NOT NULL);
        """
    }
    var queueTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS Queue(
            ID INTEGER PRIMARY KEY NOT NULL,
            QueueID TEXT NOT NULL);
        """
    }
    var operatorTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS Operator(
            ID INTEGER PRIMARY KEY NOT NULL,
            Name TEXT NOT NULL,
            PictureUrl TEXT);
        """
    }
    var engagementFileTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS EngagementFile(
            ID INTEGER PRIMARY KEY NOT NULL,
            EngagementFileID STRING,
            Url TEXT NOT NULL,
            ContentType TEXT,
            Name TEXT,
            Size REAL,
            IsDeleted INTEGER);
        """
    }
    var attachmentTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS Attachment(
            ID INTEGER PRIMARY KEY NOT NULL,
            Type INTEGER NOT NULL);
        """
    }
    var attachmentFileTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS AttachmentFile(
            ID INTEGER PRIMARY KEY NOT NULL,
            AttachmentID INTEGER NOT NULL,
            EngagementFileID INTEGER NOT NULL,
            FOREIGN KEY(AttachmentID) REFERENCES Attachment(ID),
            FOREIGN KEY(EngagementFileID) REFERENCES EngagementFile(ID));
        """
    }
    var messageTableSQL: String {
        return """
            CREATE TABLE IF NOT EXISTS Message(
            ID INTEGER PRIMARY KEY NOT NULL,
            MessageID STRING NOT NULL,
            QueueID INTEGER NOT NULL,
            OperatorID INTEGER,
            Sender TEXT NOT NULL,
            Content TEXT NOT NULL,
            AttachmentID INTEGER NOT NULL,
            Timestamp INTEGER NOT NULL,
            FOREIGN KEY(QueueID) REFERENCES Queue(ID),
            FOREIGN KEY(OperatorID) REFERENCES Operator(ID),
            FOREIGN KEY(AttachmentID) REFERENCES Attachment(ID));
        """
    }
    var queueIDIndex: String {
        return """
            CREATE UNIQUE INDEX IF NOT EXISTS index_queueid ON Queue(QueueID);
        """
    }
    var operatorNamePictureIndex: String {
        return """
            CREATE UNIQUE INDEX IF NOT EXISTS index_operator_name ON Operator(Name, PictureUrl);
        """
    }
    var messageIDIndex: String {
        return """
            CREATE UNIQUE INDEX IF NOT EXISTS index_messages_messageID ON Message(MessageID);
        """
    }
}
