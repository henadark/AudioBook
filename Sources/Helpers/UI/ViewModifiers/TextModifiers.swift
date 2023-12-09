import SwiftUI
import UIStyleKit

/// size: **14**, weight: **bold**
public struct Subhead1: ViewModifier {

    private let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .font(.appSubhead1)
            .foregroundColor(color)
    }
}

/// size: **14**, weight: **regular**
public struct Subhead2: ViewModifier {

    private let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .font(.appSubhead2)
            .foregroundColor(color)
    }
}

/// size: **12**, weight: **bold**
public struct Footnote1: ViewModifier {

    private let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .font(.appFootnote1)
            .foregroundColor(color)
    }
}

/// size: **12**, weight: **regular**
public struct Footnote2: ViewModifier {

    private let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .font(.appFootnote2.monospacedDigit())
            .foregroundColor(color)
    }
}
