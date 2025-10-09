import SwiftUI

struct VoteCountCircle: View {
    let count: Int
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            Text("\(count)")
                .font(.title2.bold())
                .frame(width: 48, height: 48)
                .background(Circle().fill(color.opacity(0.85)))
                .foregroundColor(.white)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
        }
    }
}

#Preview {
    VoteCountCircle(count: 3, color: .green, label: "Success")
}
