import SwiftUI
import Sliders
import ComposableArchitecture
import AppExtensions
import Domain

public struct AudioPlayerView: View {

    private typealias ViewState = AudioPlayerReducer.State
    private typealias Action = AudioPlayerReducer.Action
    
    // MARK: Stored Properties

    public let store: StoreOf<AudioPlayerReducer>
    @State private var toggleFlag: Bool = true

    // MARK: Init

    public init(store: StoreOf<AudioPlayerReducer>) {
        self.store = store
    }

    // MARK: Body

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            VStack(spacing: 40) {
                bookView(imageName: viewStore.state.bookImageName)
                VStack(spacing: 8) {
                    audioDescriptionView(title: viewStore.state.title, subtitle: viewStore.state.subtitle)
                    playerView(viewStore: viewStore)
                }
            }
            .padding()
            .background(Color.beige)
            .alert(store: self.store.scope(state: \.$alert, action: \.alert))
        }
    }
    
    // MARK: UI Components

    private func playerView(viewStore: ViewStore<ViewState, Action>) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(viewStore.state.currentTime)
                .footnote2_GrayTextStyle()
                .frame(height: 44)
            VStack(spacing: 8) {
                VStack(spacing: 8) {
                    valueSlider(viewStore: viewStore)
                    Button(action: { viewStore.send(.didSpeedRateButtonTap) }) {
                        Text(viewStore.state.playbackSpeed)
                            .footnote1_BlackTextStyle()
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
                playerButtonsView(viewStore: viewStore)
                Spacer()
                audioTextSwitcher
            }
            Text(viewStore.state.totalTime)
                .footnote2_GrayTextStyle()
                .frame(height: 44)
        }
    }

    private func bookView(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
    
    private func audioDescriptionView(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .subhead1_GrayTextStyle()
                .tracking(1)
                .multilineTextAlignment(.center)
                .lineLimit(1, reservesSpace: true)
            Text(subtitle)
                .subhead2_BlackTextStyle()
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
    }
    
    private func valueSlider(viewStore: ViewStore<ViewState, Action>) -> some View {
        // Had to use custom slider due to native Slider
        // doesn't have opportunity to change track height.
        ValueSlider(
            value: viewStore.binding(
                get: { $0.playbackProgress },
                send: Action.progressSliderMoving
            ),
            step: viewStore.sliderStep,
            onEditingChanged: { inProgress in
                if !inProgress {
                    viewStore.send(.didProgressSliderMove)
                }
            }
        )
        .valueSliderStyle(
            HorizontalValueSliderStyle(
                track: HorizontalTrack(view: Color.blue)
                    .background(Color.secondary.opacity(0.25))
                    .frame(height: 4)
                    .cornerRadius(2),
                thumb: Circle().foregroundColor(.accentColor),
                thumbSize: CGSize(width: 16, height: 16),
                thumbInteractiveSize: CGSize(width: 44, height: 44),
                options: .interactiveTrack
            )
        )
        .frame(height: 44)
    }
    
    private func playerButtonsView(viewStore: ViewStore<ViewState, Action>) -> some View {
        HStack(spacing: 0) {
            playerButton(
                systemImageName: "backward.end.fill",
                weight: .light,
                disabled: viewStore.state.isBackwardButtonDisbled,
                action: { viewStore.send(.didPreviousChapterButtonTap) }
            )
            Spacer()
            playerButton(
                systemImageName: "gobackward.5",
                scale: 1.8,
                disabled: viewStore.state.isGoBackwardButtonDisbled,
                action: { viewStore.send(.didRewindButtonTap) }
            )
            Spacer()
            playerButton(
                systemImageName: viewStore.state.isPlaying ? "pause.fill" : "play.fill",
                scale: 2.2,
                action: {
                    if viewStore.state.isPlaying {
                        viewStore.send(.didPauseButtonTap)
                    } else {
                        viewStore.send(.didPlayButtonTap)
                    }
                }
            )
            Spacer()
            playerButton(
                systemImageName: "goforward.10",
                scale: 1.8,
                disabled: viewStore.state.isGoForwardButtonDisbled,
                action: { viewStore.send(.didFastForwardButtonTap) }
            )
            Spacer()
            playerButton(
                systemImageName: "forward.end.fill",
                weight: .light,
                disabled: viewStore.state.isForwardButtonDisbled,
                action: { viewStore.send(.didNextChapterButtonTap) }
            )
        }
    }
    
    private func playerButton(
        systemImageName: String,
        scale: CGFloat = 1.5,
        weight: Font.Weight = .semibold,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImageName)
                .scaleEffect(scale)
                .fontWeight(weight)
        }
        .tint(.black)
        .disabled(disabled)
    }
    
    private var audioTextSwitcher: some View {
        Toggle("", isOn: $toggleFlag.animation(.easeInOut))
            .frame(width: 110, height: 55, alignment: .center)
            .toggleStyle(
                .dualIcon(
                    backgroundColor: .white,
                    borderColor: .gray,
                    selectedColor: .blue,
                    leftImageName: "headphones",
                    rightImageName: "text.alignleft",
                    scaleRightImageEffect: 0.7
                )
            )
    }
}

#Preview {
    AudioPlayerView(
        store: Store(
            initialState: AudioPlayerReducer.State(book: Book.mock)
        ) {
            AudioPlayerReducer()
        }
    )
}
