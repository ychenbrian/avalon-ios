import SwiftUI

struct PlayerCircleToggle: View {
    let name: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name.prefix(2))
                .font(.headline)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isSelected ? selectedColor : Color.gray.opacity(0.5))
                )
                .foregroundColor(.white)
        }
    }
}

#Preview {
    PlayerCircleToggle(name: "1", isSelected: false, selectedColor: Color.blue, action: {})
}
