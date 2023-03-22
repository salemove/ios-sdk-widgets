@testable import GliaWidgets
import XCTest

class IdCollectionTests: XCTestCase {
    struct User: Identifiying, Equatable {
        let id: Int
        let name: String
    }

    var users: [User] = []
    var idCollection = IdCollection<Int, User>()

    override func setUp() {
        super.setUp()
        users = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 3, name: "Charlie")
        ]
        idCollection = IdCollection(users)
    }

    override func tearDown() {
        users = []
        idCollection = []
        super.tearDown()
    }

    func testInitWithArray() {
        XCTAssertEqual(idCollection.count, 3)
        XCTAssertTrue(idCollection.contains { $0.id == 1 })
        XCTAssertTrue(idCollection.contains { $0.id == 2 })
        XCTAssertTrue(idCollection.contains { $0.id == 3 })
    }

    func testInitWithArrayLiteral() {
        let idCollection: IdCollection<Int, User> = [
            User(id: 4, name: "Dave"),
            User(id: 5, name: "Eve")
        ]
        XCTAssertEqual(idCollection.count, 2)
        XCTAssertTrue(idCollection.contains { $0.id == 4 })
        XCTAssertTrue(idCollection.contains { $0.id == 5 })
    }

    func testInsert() {
        let person = User(id: 4, name: "Dave")
        idCollection.insert(item: person, identified: person.id, at: 1)
        XCTAssertEqual(idCollection.count, 4)
        XCTAssertEqual(idCollection[1], person)
    }

    func testAppend() {
        let person = User(id: 4, name: "Dave")
        idCollection.append(item: person, identified: person.id)
        XCTAssertEqual(idCollection.count, 4)
        XCTAssertEqual(idCollection[idCollection.endIndex.advanced(by: -1)], person)
    }

    func testRemove() {
        idCollection.remove(by: 2)
        XCTAssertEqual(idCollection.count, 2)
        XCTAssertFalse(idCollection.contains { $0.id == 2 })
    }

    func testSubscript() {
        let person = idCollection[1]
        XCTAssertEqual(person.id, 2)
        XCTAssertEqual(person.name, "Bob")
    }

    func testSubscriptByIdentifier() {
        let person = idCollection[by: 3]
        XCTAssertEqual(person?.id, 3)
        XCTAssertEqual(person?.name, "Charlie")
    }

    func testIds() {
        XCTAssertEqual(idCollection.ids.count, 3)
        XCTAssertEqual(idCollection.ids[1], 2)
    }

    func testEmptyCollection() {
        let collection = IdCollection<String, Int>()
        XCTAssertTrue(collection.isEmpty)
        XCTAssertEqual(collection.count, 0)
    }

    func testAppendAndAccessByIdentifier() {
        let identifier = "identifier"
        var collection = IdCollection<String, Int>()
        collection.append(item: 10, identified: identifier)
        XCTAssertEqual(collection[by: identifier], 10)
    }

    func testInsertAndAccessAtIndex() {
        var collection = IdCollection<String, Int>()
        collection.insert(item: 10, identified: "key1", at: 0)
        collection.insert(item: 20, identified: "key2", at: 1)
        XCTAssertEqual(collection[0], 10)
        XCTAssertEqual(collection[1], 20)
    }

    func testRemoveByIdentifier() {
        let key = "key"
        var collection = IdCollection<String, Int>()
        collection.append(item: 10, identified: key)
        collection.remove(by: key)
        XCTAssertTrue(collection.isEmpty)
    }

    func tesIterations() {
        var collection = IdCollection<String, Int>()
        collection.insert(item: 10, identified: "foo", at: 0)
        collection.insert(item: 20, identified: "bar", at: 1)
        collection.insert(item: 30, identified: "baz", at: 2)

        var iterator = collection.makeIterator()
        XCTAssertEqual(iterator.next(), 10)
        XCTAssertEqual(iterator.next(), 20)
        XCTAssertEqual(iterator.next(), 30)
        XCTAssertNil(iterator.next())
    }

    func testInsertingItemWithSameIdReplacesExistingItem() {
        var idCollection = IdCollection<Int, String>()
        idCollection.insert(item: "first item", identified: 1, at: 0)
        idCollection.insert(item: "second item", identified: 2, at: 1)

        idCollection.insert(item: "new item", identified: 1, at: 0)

        XCTAssertEqual(idCollection.count, 2)
        XCTAssertEqual(idCollection[0], "new item")
        XCTAssertEqual(idCollection[1], "second item")
    }

    func testAppendingItemWithSameIdReplacesExistingItem() {
        var idCollection = IdCollection<Int, String>()
        idCollection.append(item: "first item", identified: 1)
        idCollection.append(item: "second item", identified: 2)
        idCollection.append(item: "new item", identified: 1)
        XCTAssertEqual(idCollection.count, 2)
        XCTAssertEqual(idCollection[0], "new item")
        XCTAssertEqual(idCollection[1], "second item")
    }
}
