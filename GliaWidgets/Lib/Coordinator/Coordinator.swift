protocol Coordinator {
    associatedtype Coordinated
    func start() -> Coordinated
}
