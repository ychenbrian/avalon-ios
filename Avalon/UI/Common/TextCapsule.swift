import SwiftUI

struct TextCapsule: View {
    var name: String
    var height: CGFloat = 48
    var font: Font = .headline
    var horizontalPadding: CGFloat = 16
    var filledColor: Color = .appColor(.emptyColor)
    var expandHorizontally: Bool = false

    var body: some View {
        Text(name)
            .font(font)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .frame(maxWidth: expandHorizontally ? .infinity : nil)
            .background(
                Capsule()
                    .fill(filledColor)
            )
            .overlay(
                Capsule()
                    .stroke(Color.appColor(.circleRing), lineWidth: 2)
                    .padding(3)
            )
            .foregroundColor(.appColor(.primaryTextColor))
    }
}

#Preview {
    Group {
        TextCapsule(name: "Short")
            .padding()

        TextCapsule(name: "Full Width", expandHorizontally: true)
            .padding()
    }
    .background(Color.black.opacity(0.1))
}
