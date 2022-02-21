extension Call {
    struct Environment {
        var audioSession: Glia.Environment.AudioSession
        var uuid: () -> UUID
    }
}
