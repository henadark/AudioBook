import Foundation

public enum AudioPlayerStatus: Equatable {

    case play(PlaybackInfo)
    case pause(PlaybackInfo)
    case stop
    case finish(successful: Bool)
    case error(String?)
}
