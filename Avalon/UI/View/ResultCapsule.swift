import SwiftUI

struct ResultCapsule: View {
    let displayText: String
    let backgroundColor: Color
    let requiredFail: Int
    let accessibilityLabel: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(requiredFail) fails required")
                .font(.caption)
                .foregroundColor(.primary)

            Text(displayText)
                .font(.headline)
                .frame(height: 48)
                .padding(.horizontal, 24)
                .foregroundColor(.white)
                .background(
                    Capsule()
                        .fill(backgroundColor)
                        .shadow(radius: 4)
                )
                .accessibilityLabel(accessibilityLabel)
        }
    }
}

#Preview {
    ResultCapsule(
        displayText: "Failed",
        backgroundColor: .red,
        requiredFail: 1,
        accessibilityLabel: "Quest Failed"
    )
}
