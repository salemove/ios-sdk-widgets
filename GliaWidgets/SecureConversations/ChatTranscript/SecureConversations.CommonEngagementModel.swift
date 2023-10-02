import Foundation

protocol CommonEngagementModel: AnyObject {
    var engagementAction: EngagementViewModel.ActionCallback? { get set }
    var engagementDelegate: EngagementViewModel.DelegateCallback? { get set }
    var hasViewAppeared: Bool { get }
    func event(_ event: EngagementViewModel.Event)
    func setViewAppeared()
}
