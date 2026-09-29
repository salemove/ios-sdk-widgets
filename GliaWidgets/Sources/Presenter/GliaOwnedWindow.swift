import UIKit

/// Marks windows owned by the SDK so `GliaPresenter` never selects one as the
/// host application's presentation target.
protocol GliaOwnedWindow: UIWindow {}
