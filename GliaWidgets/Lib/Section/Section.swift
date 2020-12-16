class Section<Item> {
    let index: Int

    private var items = [Item]()

    var itemCount: Int { return items.count }

    init(_ index: Int) {
        self.index = index
    }

    subscript(index: Int) -> Item {
        get { return items[index] }
        set(newValue) { items[index] = newValue }
    }

    func set(_ newItems: [Item]) {
        items.append(contentsOf: newItems)
    }

    func append(_ item: Item) {
        items.append(item)
    }

    func append(_ newItems: [Item]) {
        items.append(contentsOf: newItems)
    }
}
