import SwiftUI
import Helpers

// MARK: - Modifiers

extension View {
    
    // MARK: Text
    
    /// size: **14**, weight: **bold**
    public func subhead1_GrayTextStyle() -> some View {
        self.modifier(Subhead1(color: .gray))
    }

    /// size: **14**, weight: **regular**
    public func subhead2_BlackTextStyle() -> some View {
        self.modifier(Subhead2(color: .black))
    }

    /// size: **12**, weight: **bold**
    public func footnote1_BlackTextStyle() -> some View {
        self.modifier(Footnote1(color: .black))
    }

    /// size: **12**, weight: **regular**
    public func footnote2_GrayTextStyle() -> some View {
        self.modifier(Footnote2(color: .gray))
    }
}
