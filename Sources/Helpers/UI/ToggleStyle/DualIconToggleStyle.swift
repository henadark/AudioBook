import SwiftUI

public struct DualIconToggleStyle: ToggleStyle {

    private let backgroundColor: Color
    private let borderColor: Color
    private let selectedColor: Color
    private let leftImageName: String
    private let rightImageName: String
    private let scaleLeftImageEffect: CGFloat
    private let scaleRightImageEffect: CGFloat
    private let circleSizeMultiplier: CGFloat = 0.84
    private let horizontalPaddingMultiplier: CGFloat = 0.08

    public init(
        backgroundColor: Color,
        borderColor: Color,
        selectedColor: Color,
        leftImageName: String,
        rightImageName: String,
        scaleLeftImageEffect: CGFloat = 1.0,
        scaleRightImageEffect: CGFloat = 1.0
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.selectedColor = selectedColor
        self.leftImageName = leftImageName
        self.rightImageName = rightImageName
        self.scaleLeftImageEffect = scaleLeftImageEffect
        self.scaleRightImageEffect = scaleRightImageEffect
    }

    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { bounds in
            ZStack {
                Capsule(style: .continuous)
                    .fill(borderColor)
                ZStack {
                    backgroundColor
                    HStack {
                        if !configuration.isOn {
                            Spacer()
                        }
                        Circle()
                            .fill(selectedColor)
                            .frame(
                                width: bounds.size.height * circleSizeMultiplier,
                                height: bounds.size.height * circleSizeMultiplier,
                                alignment: .center
                            )
                        if configuration.isOn {
                            Spacer()
                        }
                    }
                    .padding(.horizontal, bounds.size.height * horizontalPaddingMultiplier)
                    HStack {
                        image(systemName: leftImageName, bounds: bounds, scale: scaleLeftImageEffect, isSelected: configuration.isOn)
                        Spacer()
                        image(systemName: rightImageName, bounds: bounds, scale: scaleRightImageEffect, isSelected: !configuration.isOn)
                    }
                    .padding(.horizontal, bounds.size.height * horizontalPaddingMultiplier)
                }
                .clipShape(
                    Capsule()
                )
                .padding(1)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }

    private func image(
        systemName: String,
        bounds: GeometryProxy,
        scale: CGFloat,
        isSelected: Bool
    ) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .fontWeight(.bold)
            .frame(
                width: bounds.size.height * circleSizeMultiplier,
                height: bounds.size.height * 0.4,
                alignment: .center
            )
            .foregroundStyle(isSelected ? .white : .black)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    Toggle("", isOn: .constant(true))
        .frame(width: 200, height: 100, alignment: .center)
        .toggleStyle(
            DualIconToggleStyle(
                backgroundColor: .gray,
                borderColor: .red,
                selectedColor: .blue,
                leftImageName: "headphones",
                rightImageName: "text.alignleft"
            )
        )
}
