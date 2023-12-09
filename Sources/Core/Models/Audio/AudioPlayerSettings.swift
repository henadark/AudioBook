import Foundation

public struct AudioPlayerSettings {

    // MARK: Stored Properties

    public let url: URL
    public let enableRate: Bool
    public let currentTime: TimeInterval
    public let rate: Float

    // MARK: Init

    public init(url: URL, enableRate: Bool = true, currentTime: TimeInterval = 0.0, rate: Float = 1.0) {
        self.url = url
        self.enableRate = enableRate
        self.currentTime = currentTime
        self.rate = rate
    }
}
