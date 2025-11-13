import SwiftUI

struct TextCircle: View {
    var name: String
    var size: CGFloat = 48
    var filledColor: Color = .appColor(.emptyColor)

    var body: some View {
        Text(name)
            .font(.headline)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(filledColor)
            )
            .overlay(
                Circle()
                    .stroke(Color.appColor(.circleRing), lineWidth: 2)
                    .padding(3)
            )
            .foregroundColor(.appColor(.primaryTextColor))
    }
}
