import SwiftUI

struct PlayerCircle: View {
    let name: String
    var body: some View {
        Text(name)
            .font(.headline)
            .frame(width: 44, height: 44)
            .background(Circle().fill(Color.blue.opacity(0.85)))
            .foregroundColor(.white)
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2)
            )
            .padding(2)
    }
}

#Preview {
    PlayerCircle(name: "1")
}
