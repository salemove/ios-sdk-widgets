class SubFlowCoordinator {
    private var subFlowCoordinators = [Any]()

    func pushCoordinator<T: FlowCoordinator>(_ coordinator: T) {
        subFlowCoordinators.append(coordinator)
    }

    func popCoordinator() {
        guard !subFlowCoordinators.isEmpty else { return }
        subFlowCoordinators.removeLast()
    }

    func removeAllCoordinators() {
        subFlowCoordinators.removeAll()
    }
}
