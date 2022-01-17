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
    var stream: Observable<MediaStream<Streamable>> {
        streamSubject
    }

    fileprivate let streamSubject = CurrentValueSubject<MediaStream<Streamable>>(.none)
}

class Call {
    let id = UUID().uuidString
    let audio = MediaChannel<AudioStreamable>()
    let video = MediaChannel<VideoStreamable>()
    let callKind: CallKind
    let mediaDirection: MediaDirection

    var state: Observable<CallState> {
        stateSubject
    }

    var duration: Observable<Int> {
        durationSubject
    }

    private let stateSubject = CurrentValueSubject<CallState>(.none)
    private let durationSubject = CurrentValueSubject<Int>(0)
    private(set) var audioPortOverride = AVAudioSession.PortOverride.none

    init(
        callKind: CallKind,
        mediaDirection: MediaDirection
    ) {
        self.callKind = callKind
        self.mediaDirection = mediaDirection
    }

    func updateAudioStream(with stream: AudioStreamable) {
        updateMediaStreamFor(
            channel: audio,
            with: stream,
            isRemote: stream.isRemote
        )
    }

    func updateVideoStream(with stream: VideoStreamable) {
        updateMediaStreamFor(
            channel: video,
            with: stream,
            isRemote: stream.isRemote
        )
    }

    func updateDuration(with duration: Int) {
        durationSubject.send(duration)
    }

    func toggleVideo() {
        video.stream.value?.localStream.map {
            if $0.isPaused {
                $0.resume()
            } else {
                $0.pause()
            }
        }
    }

    func toggleMute() {
        audio.stream.value?.localStream.map {
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
            assertionFailure(error.localizedDescription)
        }
    }

    func end() {
        audio.streamSubject.send(.none)
        video.streamSubject.send(.none)
        stateSubject.send(.ended)
    }

    private func updateMediaStreamFor<Streamable>(
        channel: MediaChannel<Streamable>,
        with stream: Streamable,
        isRemote: Bool
    ) {
        guard
            let channelStream = channel.stream.value
        else { return }

        if isRemote {
            switch channelStream {
            case .none, .remote:
                channel.streamSubject.send(.remote(stream))

            case .local(let local):
                channel.streamSubject.send(.twoWay(local: local, remote: stream))

            case .twoWay(local: let local, remote: _):
                channel.streamSubject.send(.twoWay(local: local, remote: stream))
            }
        } else {
            switch channelStream {
            case .none, .local:
                channel.streamSubject.send(.local(stream))

            case .remote(let remote):
                channel.streamSubject.send(.twoWay(local: stream, remote: remote))

            case .twoWay(local: _, remote: let remote):
                channel.streamSubject.send(.twoWay(local: stream, remote: remote))
            }
        }

        updateStarted()
    }

    private func updateStarted() {
       guard [.none, .upgrading].contains(stateSubject.value) else { return }

        switch callKind {
        case .audio:
           switch audio.stream.value {
           case .twoWay:
               stateSubject.send(.started)

           default:
               break
           }

        case .video:
           switch video.stream.value {
           case .remote:
               if mediaDirection == .oneWay {
                   stateSubject.send(.started)
               }

           case .twoWay:
               if mediaDirection == .twoWay {
                   stateSubject.send(.started)
               }

           default:
               break
           }
       }
    }
}
