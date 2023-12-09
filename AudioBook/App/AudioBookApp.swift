import SwiftUI
import ComposableArchitecture
import Presentation
import Domain

@main
struct AudioBookApp: App {
    var body: some Scene {
        WindowGroup {
            AudioPlayerView(
                store: Store(
                    initialState: AudioPlayerReducer.State(book: Book.mock)
                ) {
                    AudioPlayerReducer()._printChanges()
                }
            )
        }
    }
}
