import Foundation
import Core

public enum PlaybackInfoBuilder {

    public static func build(from audioPlayerManager: AudioPlayerManager?) -> PlaybackInfo {
        return PlaybackInfo(
            currentTime: audioPlayerManager?.currentTime ?? 0,
            duration: audioPlayerManager?.duration ?? 0
        )
    }

    public static func build(from bookChapter: Book.Chapter?, isFinish: Bool = true) -> PlaybackInfo {
        return PlaybackInfo(
            currentTime: isFinish ? (bookChapter?.duration ?? 0) : 0,
            duration: bookChapter?.duration ?? 0
        )
    }
}
