import Foundation
@preconcurrency import AVFoundation

public final class AudioPlayerManager: NSObject, AVAudioPlayerDelegate, Sendable {

    // MARK: Stored Properties

    private let didFinishPlaying: @Sendable (Bool) -> Void
    private let decodeErrorDidOccur: @Sendable (Error?) -> Void
    private let player: AVAudioPlayer

    // MARK: Init

    public init(
        audioPlayerSettings: AudioPlayerSettings,
        didFinishPlaying: @escaping @Sendable (Bool) -> Void,
        decodeErrorDidOccur: @escaping @Sendable (Error?) -> Void
    ) throws {
        self.didFinishPlaying = didFinishPlaying
        self.decodeErrorDidOccur = decodeErrorDidOccur
        self.player = try AVAudioPlayer(contentsOf: audioPlayerSettings.url)
        super.init()
        player.delegate = self
        setupPlayer(with: audioPlayerSettings)
    }

    // MARK: Audio Player

    public func setupPlayer(with settings: AudioPlayerSettings) {
        player.enableRate = settings.enableRate
        player.prepareToPlay()
        player.currentTime = settings.currentTime
        player.rate = settings.rate
    }

    public func play() {
        player.play()
    }

    public func pause() {
        player.pause()
    }

    public func stop() {
        player.stop()
    }

    public var isPlaying: Bool { player.isPlaying }

    public var currentTime: TimeInterval { 
        get { player.currentTime }
        set { player.currentTime = newValue }
    }

    // '0.1' is workaround to play next track if user fast forward to the end current track.
    public var duration: TimeInterval { player.duration - 0.1 }

    public var speedRate: Float {
        get { player.rate }
        set { player.rate = newValue }
    }

    // MARK: AVAudioPlayerDelegate

    public func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        didFinishPlaying(flag)
    }

    public func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        decodeErrorDidOccur(error)
    }
}
