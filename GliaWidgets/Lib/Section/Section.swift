import Foundation

class Section<Item> {
    let index: Int
    var items: [Item] { return items_ }
    var itemCount: Int { return items_.count }

    private var items_ = [Item]()

    init(_ index: Int) {
        self.index = index
    }

    subscript(index: Int) -> Item {
        get { return items_[index] }
        set(newValue) { items_[index] = newValue }
    }

    func set(_ newItems: [Item]) {
        items_ = newItems
    }

    func append(_ item: Item) {
        items_.append(item)
    }

    func append(_ newItems: [Item]) {
        items_.append(contentsOf: newItems)
    }

    func replaceItem(at index: Int, with item: Item) {
        items_[index] = item
    }

    func item(after index: Int) -> Item? {
        guard index + 1 < itemCount else { return nil }
        return items_[index + 1]
    }

    func remoteItem(at index: Int) {
        items_.remove(at: index)
    }
}
