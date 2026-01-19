import SwiftUI

final class RemoteImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?

    struct Cache {
        var setImageForKey: (_ image: UIImage?, _ key: String) -> Void
        var getImageForKey: (_ key: String) -> UIImage?
    }

    struct Environment {
        let cache: Cache
    }

    private let environment: Environment
    private var task: Task<Void, Never>?

    init(environment: Environment) { self.environment = environment }
    deinit { cancel() }

    func cancel() {
        task?.cancel()
        task = nil
        image = nil
    }

    func load(from urlString: String?) {
        task?.cancel()
        task = nil

        guard let urlString, let url = URL(string: urlString) else {
            image = nil
            return
        }

        if let cached = environment.cache.getImageForKey(urlString) {
            image = cached
            return
        }

        task = Task { @MainActor [environment] in
            let fetched = await Self.fetchImage(url: url)
            guard !Task.isCancelled else { return }

            if let fetched { environment.cache.setImageForKey(fetched, urlString) }
            self.image = fetched
        }
    }

    private static func fetchImage(url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse).map({ (200...299).contains($0.statusCode) }) ?? true else {
                return nil
            }
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}

extension RemoteImageLoader.Cache {
    static func from(_ cache: ImageView.Cache) -> Self {
        .init(
            setImageForKey: { image, key in
                cache.setImageForKey(image, key)
            },
            getImageForKey: { key in
                cache.getImageForKey(key)
            }
        )
    }
}
