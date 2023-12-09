import SwiftUI
import Helpers

extension ToggleStyle where Self == DualIconToggleStyle {

    public static func dualIcon(
        backgroundColor: Color,
        borderColor: Color,
        selectedColor: Color,
        leftImageName: String,
        rightImageName: String,
        scaleLeftImageEffect: CGFloat = 1.0,
        scaleRightImageEffect: CGFloat = 1.0
    ) -> DualIconToggleStyle {
        DualIconToggleStyle(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            selectedColor: selectedColor,
            leftImageName: leftImageName,
            rightImageName: rightImageName,
            scaleLeftImageEffect: scaleLeftImageEffect,
            scaleRightImageEffect: scaleRightImageEffect
        )
    }
}
