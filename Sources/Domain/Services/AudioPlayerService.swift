import Foundation
import ComposableArchitecture
import Core

public struct AudioPlayerService {

    // MARK: Stored Propeties

    public var play: @Sendable (URL, PlaybackInfo, Float) -> AsyncStream<AudioPlayerStatus>
    public var pause: @Sendable () async -> Void
    public var playbackTimeAndPause: @Sendable (TimeInterval) async -> Void
    public var playbackTimeAndPlay: @Sendable (TimeInterval) async -> Void
    public var speedRate: @Sendable (Float) async -> Void
}

extension AudioPlayerService: DependencyKey {

    private final class Container {

        internal var audioPlayerManager: AudioPlayerManager?
        internal var continuation: AsyncStream<AudioPlayerStatus>.Continuation?

        internal init() {}
    }

    // MARK: DependencyKey

    public static let liveValue: AudioPlayerService = {
        let container = Container()

        return AudioPlayerService(
            play: { url, playbackInfo, speedRate in

                let stream = AsyncStream<AudioPlayerStatus> { continuation in
                    do {

                        // Init stored properties.
                        container.continuation = continuation
                        container.audioPlayerManager = try AudioPlayerManager(
                            audioPlayerSettings: AudioPlayerSettings(url: url, currentTime: playbackInfo.currentTime, rate: speedRate),
                            didFinishPlaying: { successful in
                                continuation.yield(.finish(successful: successful))
                                continuation.finish()
                            },
                            decodeErrorDidOccur: { error in
                                continuation.yield(.error(error?.localizedDescription))
                                continuation.finish()
                            }
                        )
                        container.audioPlayerManager?.play()

                        // Init Clock to track progress.
                        let timerTask = Task {
                            let clock = ContinuousClock()
                            for await _ in clock.timer(interval: .milliseconds(500)) {
                                guard let manager = container.audioPlayerManager, manager.isPlaying else { continue }

                                let info = PlaybackInfoBuilder.build(from: manager)
                                continuation.yield(.play(info))
                            }
                        }

                        continuation.onTermination = { _ in
                            container.audioPlayerManager?.stop()
                            timerTask.cancel()
                        }
                    } catch {
                        continuation.yield(.error(error.localizedDescription))
                        continuation.finish()
                    }
                }
                return stream
            },
            pause: {
                container.audioPlayerManager?.pause()
                container.continuation?.yield(.pause(PlaybackInfoBuilder.build(from: container.audioPlayerManager)))
            },
            playbackTimeAndPause: { progress in
                guard let manager = container.audioPlayerManager else { return }

                let progress = min(1, max(0, progress))
                let time = manager.duration * progress

                if manager.isPlaying {
                    manager.pause()
                }
                manager.currentTime = time

                container.continuation?.yield(.pause(PlaybackInfoBuilder.build(from: manager)))
            },
            playbackTimeAndPlay: { progress in
                guard let manager = container.audioPlayerManager else { return }

                let progress = min(1, max(0, progress))
                let time = manager.duration * progress

                manager.currentTime = time
                if !manager.isPlaying {
                    manager.play()
                }

                container.continuation?.yield(.play(PlaybackInfoBuilder.build(from: manager)))
            },
            speedRate: { speedRate in
                guard let manager = container.audioPlayerManager, manager.isPlaying else { return }
                manager.speedRate = speedRate
            }
        )
    }()
}

extension DependencyValues {

    public var audioPlayerService: AudioPlayerService {
        get { self[AudioPlayerService.self] }
        set { self[AudioPlayerService.self] = newValue }
    }
}
