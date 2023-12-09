// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let uiStyleKit = "UIStyleKit"
let helpers = "Helpers"
let swiftExtensions = "SwiftExtensions"
let appExtensions = "AppExtensions"
let core = "Core"
let domain = "Domain"
let presentation = "Presentation"

let package = Package(
    name: "AudioBook",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: uiStyleKit, targets: [uiStyleKit]),
        .library(name: helpers, targets: [helpers]),
        .library(name: swiftExtensions, targets: [swiftExtensions]),
        .library(name: appExtensions, targets: [appExtensions]),
        .library(name: core, targets: [core]),
        .library(name: domain, targets: [domain]),
        .library(name: presentation, targets: [presentation]),
    ],
    dependencies: [
        // ComposableArchitecture.
        // A library for building applications in a consistent and understandable way,
        // with composition, testing, and ergonomics in mind.
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.5.3"),

        // Sliders
        // SwiftUI Sliders with custom styles.
        .package(url: "https://github.com/spacenation/swiftui-sliders", from: "2.1.0"),
    ],
    targets: [
        .target(name: swiftExtensions),
        .target(name: uiStyleKit),
        .target(
            name: helpers,
            dependencies: [
                .byName(name: uiStyleKit),
            ]
        ),
        .target(
            name: appExtensions,
            dependencies: [
                .byName(name: helpers),
            ]
        ),
        .target(
            name: core
        ),
        .target(
            name: domain,
            dependencies: [
                .byName(name: core),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: presentation,
            dependencies: [
                .byName(name: swiftExtensions),
                .byName(name: uiStyleKit),
                .byName(name: appExtensions),
                .byName(name: domain),
                .product(name: "Sliders", package: "swiftui-sliders")
            ]
        ),
    ]
)
