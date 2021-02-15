import SalemoveSDK
import AVFoundation

enum CallKind {
    case audio
    case video

    init?(with offer: MediaUpgradeOffer) {
        switch offer.type {
        case .audio:
            self = .audio
        case .video:
            self = .video
        default:
            return nil
        }
    }
}

enum CallState {
    case none
    case started
    case upgrading
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
}

class MediaChannel<Streamable> {
    let stream = ValueProvider<MediaStream<Streamable>>(with: .none)
    private(set) var neededDirection: MediaDirection = .twoWay

    func setNeededDirection(_ direction: MediaDirection) {
        neededDirection = direction
    }
}

class Call {
    let id = UUID().uuidString
    let kind = ValueProvider<CallKind>(with: .audio)
    let state = ValueProvider<CallState>(with: .none)
    let duration = ValueProvider<Int>(with: 0)
    let audio = MediaChannel<AudioStreamable>()
    let video = MediaChannel<VideoStreamable>()
    private(set) var audioPortOverride = AVAudioSession.PortOverride.none

    init(_ kind: CallKind) {
        self.kind.value = kind
    }

    func upgrade(to offer: MediaUpgradeOffer) {
        setKind(for: offer.type)
        setNeededDirection(offer.direction, for: offer.type)
        state.value = .upgrading
    }

    func updateAudioStream(with stream: AudioStreamable) {
        updateMediaStream(audio.stream,
                          with: stream,
                          isRemote: stream.isRemote)
    }

    func updateVideoStream(with stream: VideoStreamable) {
        updateMediaStream(video.stream,
                          with: stream,
                          isRemote: stream.isRemote)
    }

    func toggleVideo() {
        video.stream.value.localStream.map {
            if $0.isPaused {
                $0.resume()
            } else {
                $0.pause()
            }
        }
    }

    func toggleMute() {
        audio.stream.value.localStream.map {
            if $0.isMuted {
                $0.unmute()
            } else {
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

        let session = AVAudioSession.sharedInstance()
        do {
            try session.overrideOutputAudioPort(newOverride)
            audioPortOverride = newOverride
        } catch {
            print(error)
        }
    }

    func end() {
        state.value = .ended
    }

    private func setKind(for type: MediaType) {
        switch type {
        case .audio:
            kind.value = .audio
        case .video:
            kind.value = .video
        default:
            break
        }
    }

    private func setNeededDirection(_ direction: MediaDirection, for type: MediaType) {
        switch type {
        case .audio:
            audio.setNeededDirection(direction)
        case .video:
            video.setNeededDirection(direction)
        default:
            break
        }
    }

    private func updateMediaStream<Streamable>(_ mediaStream: ValueProvider<MediaStream<Streamable>>,
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
        guard [.none, .upgrading].contains(state.value) else { return }

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
