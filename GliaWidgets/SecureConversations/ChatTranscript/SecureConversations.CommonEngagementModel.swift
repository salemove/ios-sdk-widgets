import Foundation

protocol CommonEngagementModel: AnyObject {
    var engagementAction: EngagementViewModel.ActionCallback? { get set }
    var engagementDelegate: EngagementViewModel.DelegateCallback? { get set }
    func event(_ event: EngagementViewModel.Event)
}
