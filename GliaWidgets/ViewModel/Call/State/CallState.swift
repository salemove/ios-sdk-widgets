enum CallState {
    case none
    case started(CallKind)
    case progressed(CallKind, duration: Int)
    case ended(CallKind, duration: Int)
}
