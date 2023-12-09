import Foundation
import ComposableArchitecture
import Domain
import SwiftExtensions

@Reducer
public struct AudioPlayerReducer {

    public struct State: Equatable {

        fileprivate enum PlaybackSpeedRate: String, Equatable  {

            case x0_5 = "x0.5"
            case x1 = "x1"
            case x1_5 = "x1.5"
            case x2 = "x2"

            fileprivate var multiplier: Float {
                switch self {
                case .x0_5: return 0.5
                case .x1: return 1.0
                case .x1_5: return 1.5
                case .x2: return 2.0
                }
            }

            fileprivate var nextState: Self {
                switch self {
                case .x0_5:
                    return .x1
                case .x1:
                    return .x1_5
                case .x1_5:
                    return .x2
                case .x2:
                    return .x0_5
                }
            }
        }

        // MARK: Stored Properties

        // Domain
        fileprivate var book: Book
        fileprivate var currentChapterIndex: Int
        fileprivate var currentChapter: Book.Chapter? { book.chapters[safe: currentChapterIndex] }
        fileprivate var playbackInfo: PlaybackInfo
        fileprivate var playbackSpeedRate: PlaybackSpeedRate = .x1

        // UI
        @PresentationState var alert: AlertState<Action.Alert>?
        internal fileprivate(set) var isMovingSlider: Bool = false
        internal fileprivate(set) var isPlaying: Bool = false
        internal var bookImageName: String { book.imageName }
        internal var title: String { "KEY POINT \(currentChapterIndex + 1) OF \(book.chapters.count)" }
        internal var subtitle: String { currentChapter?.description ?? "" }
        internal var playbackProgress: Double { playbackInfo.progress }
        internal var currentTime: String { playbackInfo.currentTime.format(using: [.minute, .second]) }
        internal var totalTime: String { playbackInfo.duration.format(using: [.minute, .second]) }
        internal var sliderStep: Double { 1 / playbackInfo.duration }
        internal var playbackSpeed: String { "Speed \(playbackSpeedRate.rawValue)" }
        internal var isBackwardButtonDisbled: Bool { currentChapterIndex == 0 }
        internal var isGoBackwardButtonDisbled: Bool { false }
        internal var isGoForwardButtonDisbled: Bool { false }
        internal var isForwardButtonDisbled: Bool { currentChapterIndex == book.chapters.count - 1 }

        // MARK: Init

        public init(book: Book, currentChapterIndex: Int = 0) {
            self.book = book
            self.currentChapterIndex = currentChapterIndex
            self.playbackInfo = PlaybackInfoBuilder.build(from: book.chapters.first, isFinish: false)
        }
    }

    // MARK: -

    public enum Action: Equatable {

        public enum Alert: Equatable {}

        case audioPlayer(AudioPlayerStatus)
        case updateChapterIfNeeded
        case alert(PresentationAction<Alert>)

        // Actions
        case didSpeedRateButtonTap
        case didPlayButtonTap
        case didPauseButtonTap
        case didFastForwardButtonTap
        case didRewindButtonTap
        case progressSliderMoving(Double)
        case didProgressSliderMove
        case didNextChapterButtonTap
        case didPreviousChapterButtonTap
    }

    private enum CancelID { case play, playbackProgress }

    // MARK: -
    // MARK: Stored Properties

    @Dependency(\.audioPlayerService) var audioPlayerService

    // MARK: Init

    public init() { }

    // MARK: Reducer Body

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .audioPlayer(playerStatus):
                switch playerStatus {
                case let .play(info):
                    state.playbackInfo = info
                    return .send(.updateChapterIfNeeded, animation: .default)
                case let .pause(info):
                    state.playbackInfo = info
                    return .none
                case .stop:
                    return .none
                case let .error(message):
                    state.alert = AlertState { TextState("Audio player error message: \(message ?? "Undefined error")") }
                    return .none
                case .finish:
                    state.playbackInfo = PlaybackInfoBuilder.build(from: state.currentChapter)
                    return .send(.updateChapterIfNeeded, animation: .default)
                }

            case .updateChapterIfNeeded:
                if state.playbackInfo.progress == 1 {
                    // Next chapter.
                    state.currentChapterIndex = (state.currentChapterIndex + 1) % state.book.chapters.count

                    // If last chapter has been listened, stop player.
                    if state.currentChapterIndex == 0 {
                        state.isPlaying = false
                    }

                    state.playbackInfo = PlaybackInfoBuilder.build(from: state.currentChapter, isFinish: false)

                    if state.isPlaying {
                        return .send(.didPlayButtonTap)
                    }
                }

                return .none

            case .alert:
                return .none

            case .didSpeedRateButtonTap:
                state.playbackSpeedRate = state.playbackSpeedRate.nextState

                return .run { [speedRate = state.playbackSpeedRate.multiplier] send in
                    await audioPlayerService.speedRate(speedRate)
                }

            case .didPlayButtonTap:

                let fileName = state.currentChapter?.audioFileName
                guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
                    return .send(.audioPlayer(.error("Audio file '\(fileName ?? "-")' not found")))
                        .cancellable(id: CancelID.play, cancelInFlight: true)
                }

                state.isPlaying = true

                return .run { [playbackInfo = state.playbackInfo, speed = state.playbackSpeedRate] send in
                    for await status in self.audioPlayerService.play(url, playbackInfo, speed.multiplier) {
                        await send(.audioPlayer(status))
                    }
                }
                .cancellable(id: CancelID.play, cancelInFlight: true)

            case .didPauseButtonTap:
                state.isPlaying = false

                return .run { _ in
                    await audioPlayerService.pause()
                }
                .merge(with: .cancel(id: CancelID.play))

            case .didFastForwardButtonTap:
                state.playbackInfo = state.playbackInfo.fastForwardCurrentTime(by: 10)

                return .send(.didProgressSliderMove)
                    .cancellable(id: CancelID.playbackProgress, cancelInFlight: true)

            case .didRewindButtonTap:
                state.playbackInfo = state.playbackInfo.rewindCurrentTime(by: 5)

                return .send(.didProgressSliderMove)
                    .cancellable(id: CancelID.playbackProgress, cancelInFlight: true)

            case let .progressSliderMoving(progress):
                state.playbackInfo = state.playbackInfo.withUpdated(progress: progress)
                state.isMovingSlider = true

                return .run { [progress = state.playbackInfo.progress] _ in
                    await audioPlayerService.playbackTimeAndPause(progress)
                }
                .cancellable(id: CancelID.playbackProgress, cancelInFlight: true)

            case .didProgressSliderMove:
                state.isMovingSlider = false

                return .run { [progress = state.playbackInfo.progress] _ in
                    await audioPlayerService.playbackTimeAndPlay(progress)
                }

            case .didNextChapterButtonTap:
                state.playbackInfo = state.playbackInfo.withUpdated(progress: 1)

                return .send(.updateChapterIfNeeded)

            case .didPreviousChapterButtonTap:
                guard state.currentChapterIndex > 0 else {
                    assertionFailure()
                    return .none
                }
                state.currentChapterIndex -= 1
                state.playbackInfo = PlaybackInfoBuilder.build(from: state.currentChapter, isFinish: false)

                if state.isPlaying {
                    return .send(.didPlayButtonTap)
                }
                return .none
            }
        }
    }
}
