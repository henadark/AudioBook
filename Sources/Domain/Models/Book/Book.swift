import Foundation

public struct Book: Identifiable, Equatable {

    public struct Chapter: Equatable {

        // MARK: Stored Properties

        public var description: String
        public var audioFileName: String
        public var duration: TimeInterval

        // MARK: Init

        public init(description: String, audioFileName: String, duration: TimeInterval) {
            self.description = description
            self.audioFileName = audioFileName
            self.duration = duration
        }
    }

    // MARK: Stored Properties

    public var id: UUID
    public var imageName: String
    public var chapters: [Chapter]

    // MARK: Init

    public init(id: UUID = UUID(), imageName: String, chapters: [Chapter]) {
        self.id = id
        self.imageName = imageName
        self.chapters = chapters
    }

    // MARK: Mock

    public static var mock: Book {
        Book(
            imageName: "book",
            chapters: [
                Chapter(
                    description: "Chapter 1: Design is not how a thing looks, but how it works",
                    audioFileName: "chapter_1",
                    duration: 330
                ),
                Chapter(
                    description: "Chapter 2: Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    audioFileName: "chapter_2",
                    duration: 280
                ),
                Chapter(
                    description: "Chapter 3: Maecenas aliquam molestie mollis. Nunc a nunc augue.",
                    audioFileName: "chapter_3",
                    duration: 183
                )
            ]
        )
    }
}
