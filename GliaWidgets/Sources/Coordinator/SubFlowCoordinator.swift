import Foundation

class SubFlowCoordinator {
    private var subFlowCoordinators: [any FlowCoordinator] = []

    var coordinators: [any FlowCoordinator] { subFlowCoordinators }

    func pushCoordinator(_ coordinator: any FlowCoordinator) {
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
