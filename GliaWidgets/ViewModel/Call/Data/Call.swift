import SalemoveSDK

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

class Audio {
    let stream = ValueProvider<MediaStream<AudioStreamable>>(with: .none)
}

class Video {
    let stream = ValueProvider<MediaStream<VideoStreamable>>(with: .none)
}

class Call {
    let id = UUID().uuidString
    let kind = ValueProvider<CallKind>(with: .audio)
    let state = ValueProvider<CallState>(with: .none)
    let audio = Audio()
    let video = Video()
    let duration = ValueProvider<Int>(with: 0)

    init(_ kind: CallKind) {
        self.kind.value = kind
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
    }
}
