import Foundation

#if DEBUG
extension FileSystemStorage.Environment {
    static func mock(
        fileManager: FoundationBased.FileManager = .mock,
        data: FoundationBased.Data = .mock,
        date: @escaping () -> Date = { .mock }
    ) -> Self {
        .init(
            fileManager: fileManager,
            data: data,
            date: date
        )
    }
}
#endif
