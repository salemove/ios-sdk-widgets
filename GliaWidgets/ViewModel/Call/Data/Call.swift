import Foundation
import AVFoundation

enum CallKind {
    case audio
    case video(direction: CoreSdkClient.MediaDirection)

    init?(with offer: CoreSdkClient.MediaUpgradeOffer) {
        switch offer.type {
        case .audio:
            self = .audio
        case .video:
            self = .video(direction: offer.direction)
        default:
            return nil
        }
    }
}

extension CallKind: Equatable {
    static func == (lhs: CallKind, rhs: CallKind) -> Bool {
        switch (lhs, rhs) {
        case (.audio, .audio):
            return true

        case (.video(let lhsDirection), .video(let rhsDirection)):
            return lhsDirection == rhsDirection

        default:
            return false
        }
    }
}

extension CallKind {
    var mediaDirection: CoreSdkClient.MediaDirection {
        switch self {
        case .audio:
            return .twoWay

        case .video(let direction):
            return direction
        }
    }
}

enum CallState {
    case none
    case started
    case connecting
    case ended
}

enum MediaStream<Streamable> {
    case none
    case remote(Streamable)
    case local(Streamable)
    case twoWay(local: Streamable, remote: Streamable)

    var hasLocalStream: Bool { return localStream != nil }
    var localStream: Streamable? {
        switch self {
        case .local(let stream):
            return stream
        case .twoWay(local: let stream, _):
            return stream
        default:
            return nil
        }
    }
    var hasRemoteStream: Bool { return remoteStream != nil }
    var remoteStream: Streamable? {
        switch self {
        case .remote(let stream):
            return stream
        case .twoWay(_, remote: let stream):
            return stream
        default:
            return nil
        }
    }

    var isNone: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
}

class MediaChannel<Streamable> {
    let stream = ObservableValue<MediaStream<Streamable>>(with: .none)
    private(set) var neededDirection: CoreSdkClient.MediaDirection = .twoWay

    func setNeededDirection(_ direction: CoreSdkClient.MediaDirection) {
        neededDirection = direction
    }
}

class Call {
    let id: String
    let kind = ObservableValue<CallKind>(with: .audio)
    let state = ObservableValue<CallState>(with: .none)
    let duration = ObservableValue<Int>(with: 0)
    let audio = MediaChannel<CoreSdkClient.AudioStreamable>()
    let video = MediaChannel<CoreSdkClient.VideoStreamable>()
    let isVisitorOnHold = ObservableValue<Bool>(with: false)

    var environment: Environment
    private(set) var audioPortOverride = AVAudioSession.PortOverride.none
    private(set) var hasVisitorMutedAudio: Bool
    private(set) var hasVisitorTurnedOffVideo: Bool

    init(_ kind: CallKind, environment: Environment) {
        self.id = environment.uuid().uuidString
        self.kind.value = kind
        self.environment = environment
        self.hasVisitorMutedAudio = kind.mediaDirection == .oneWay
        self.hasVisitorTurnedOffVideo = kind.mediaDirection == .oneWay
    }

    func transfer() {
        audio.stream.value = .none
        video.stream.value = .none
        state.value = .connecting
    }

    func upgrade(to offer: CoreSdkClient.MediaUpgradeOffer) {
        setKind(for: offer.type, direction: offer.direction)
        setNeededDirection(offer.direction, for: offer.type)
        state.value = .connecting
    }

    func updateAudioStream(with stream: CoreSdkClient.AudioStreamable) {
        updateMediaStream(audio.stream,
                          with: stream,
                          isRemote: stream.isRemote)

        if stream.isRemote {
            stream.onHold = { [weak self] in
                self?.isVisitorOnHold.value = $0
            }
        }
    }

    func updateVideoStream(with stream: CoreSdkClient.VideoStreamable) {
        updateMediaStream(video.stream,
                          with: stream,
                          isRemote: stream.isRemote)

        if stream.isRemote {
            stream.onHold = { [weak self] in
                self?.isVisitorOnHold.value = $0
            }
        }
    }

    func toggleVideo() {
        video.stream.value.localStream.map {
            if $0.isPaused {
                self.hasVisitorTurnedOffVideo = false
                $0.resume()
            } else {
                self.hasVisitorTurnedOffVideo = true
                $0.pause()
            }
        }
    }

    func toggleMute() {
        audio.stream.value.localStream.map {
            if $0.isMuted {
                self.hasVisitorMutedAudio = false
                $0.unmute()
            } else {
                self.hasVisitorMutedAudio = true
                $0.mute()
            }
        }
    }

    func toggleSpeaker() {
        let newOverride: AVAudioSession.PortOverride = {
            switch audioPortOverride {
            case .none:
                return .speaker
            case .speaker:
                return .none
            @unknown default:
                return .none
            }
        }()

        let session = environment.audioSession

        do {
            try session.overrideOutputAudioPort(newOverride)
            audioPortOverride = newOverride
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func end() {
        audio.stream.value = .none
        video.stream.value = .none
        state.value = .ended
    }

    private func setKind(for type: CoreSdkClient.MediaType, direction: CoreSdkClient.MediaDirection) {
        switch type {
        case .audio:
            kind.value = .audio
        case .video:
            kind.value = .video(direction: direction)
        default:
            break
        }
    }

    private func setNeededDirection(_ direction: CoreSdkClient.MediaDirection, for type: CoreSdkClient.MediaType) {
        switch type {
        case .audio:
            audio.setNeededDirection(direction)
        case .video:
            video.setNeededDirection(direction)
        default:
            break
        }
    }

    private func updateMediaStream<Streamable>(_ mediaStream: ObservableValue<MediaStream<Streamable>>,
                                               with stream: Streamable,
                                               isRemote: Bool) {
        if isRemote {
            switch mediaStream.value {
            case .none, .remote:
                mediaStream.value = .remote(stream)
            case .local(let local):
                mediaStream.value = .twoWay(local: local, remote: stream)
            case .twoWay(local: let local, remote: _):
                mediaStream.value = .twoWay(local: local, remote: stream)
            }
        } else {
            switch mediaStream.value {
            case .none, .local:
                mediaStream.value = .local(stream)
            case .remote(let remote):
                mediaStream.value = .twoWay(local: stream, remote: remote)
            case .twoWay(local: _, remote: let remote):
                mediaStream.value = .twoWay(local: stream, remote: remote)
            }
        }

        updateStarted()
    }

    private func updateStarted() {
        guard [.none, .connecting].contains(state.value) else { return }

        switch kind.value {
        case .audio:
            switch audio.stream.value {
            case .twoWay:
                state.value = .started
            default:
                break
            }
        case .video:
            switch video.stream.value {
            case .remote:
                if video.neededDirection == .oneWay {
                    state.value = .started
                }
            case .twoWay:
                if video.neededDirection == .twoWay {
                    state.value = .started
                }
            default:
                break
            }
        }
    }
}
