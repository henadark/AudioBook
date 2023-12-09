import SwiftUI

extension Font {

    public static func appFont(size: CGFloat = 14.0, weight: Weight? = nil, design: Design? = .rounded) -> Font {
        Font.system(size: size, weight: weight, design: design)
    }
    
    /// size: **14**, weight: **bold**
    public static let appSubhead1: Font = Font.appFont(size: 14, weight: .bold)
    /// size: **14**, weight: **regular**
    public static let appSubhead2: Font = Font.appFont(size: 14, weight: .regular)
    /// size: **12**, weight: **bold**
    public static let appFootnote1: Font = Font.appFont(size: 12, weight: .bold)
    /// size: **12**, weight: **regular**
    public static let appFootnote2: Font = Font.appFont(size: 12, weight: .regular)
}
