/// Collection that allows easier access by element identifier.
struct IdCollection<Identifier: Hashable, Item: Equatable>: Equatable, Collection {

    typealias DictionaryType = [Identifier: Item]
    typealias ArrayType = [Identifier]

    private var items = [Identifier: Item]()
    private var list = [Identifier]()

    // Required nested types, that tell Swift what our collection contains
    typealias Index = ArrayType.Index
    typealias Element = DictionaryType.Value

    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index { return list.startIndex }
    var endIndex: Index { return list.endIndex }

    // Required subscript, based on a array index
    subscript(index: Index) -> Element {
        items[list[index]].unsafelyUnwrapped
    }

    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        list.index(after: i)
    }

    subscript(by key: DictionaryType.Key) -> DictionaryType.Value? {
        items[key]
    }

    mutating func insert(
        item: Item,
        identified by: Identifier,
        at index: Int
    ) {
        var prevIdx: Index?
        if items[by] != nil, let idx = list.firstIndex(of: by) {
            prevIdx = idx
            list.remove(at: idx)
        }
        items[by] = item
        list.insert(by, at: prevIdx ?? index)
    }

    @inlinable mutating func append(
        item: Item,
        identified by: Identifier
    ) {
        insert(
            item: item,
            identified: by,
            at: list.endIndex
        )
    }

    mutating func remove(by identifier: Identifier) {
        if items[identifier] != nil, let idx = list.firstIndex(of: identifier) {
            list.remove(at: idx)
            items[identifier] = nil
        }
    }

    var ids: ArraySlice<Identifier> {
        list[...]
    }
}

/// Copy of `Identifiable` protocol. This will be removed in future
/// in favor of `Identifiable`. But for now it is need because `Identifiable`
/// is not available in iOS 12.
protocol Identifiying {
    // swiftlint:disable type_name
    /// A type representing the stable identity of the entity associated with
    /// an instance.
    associatedtype ID: Hashable
    // swiftlint:enable type_name

    /// The stable identity of the entity associated with this instance.
    var id: Self.ID { get }
}

extension IdCollection: ExpressibleByArrayLiteral where Item: Identifiying, Item.ID == Identifier {
    init(arrayLiteral elements: Item...) {
        for element in elements {
            self.append(item: element, identified: element.id)
        }
    }
}

extension IdCollection where Item: Identifiying, Item.ID == Identifier {
    init(_ elements: [Item]) {
        for element in elements {
            self.append(item: element, identified: element.id)
        }
    }
}
