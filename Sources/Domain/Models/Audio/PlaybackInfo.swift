import Foundation

public struct PlaybackInfo: Equatable {

    // MARK: Stored Properties

    public var currentTime: TimeInterval
    public var duration: TimeInterval

    // MARK: Init

    internal init(currentTime: TimeInterval = 0, duration: TimeInterval = 0) {
        self.currentTime = currentTime
        self.duration = duration
    }

    // MARK: Helpers

    public var progress: Double { currentTime / duration }

    public var timeLeft: Double { duration - currentTime }

    // MARK: New Object With Changes

    public func fastForwardCurrentTime(by seconds: TimeInterval) -> PlaybackInfo {
        var newCurrentTime = currentTime + seconds
        if newCurrentTime > duration {
            newCurrentTime = duration
        }
        return PlaybackInfo(currentTime: newCurrentTime, duration: duration)
    }

    public func rewindCurrentTime(by seconds: TimeInterval) -> PlaybackInfo {
        var newCurrentTime = currentTime - seconds
        if newCurrentTime < 0 {
            newCurrentTime = 0
        }
        return PlaybackInfo(currentTime: newCurrentTime, duration: duration)
    }

    public func withUpdated(progress: Double) -> PlaybackInfo {
        PlaybackInfo(currentTime: progress * duration, duration: duration)
    }
}
