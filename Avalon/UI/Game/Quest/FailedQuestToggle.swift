import SwiftUI

struct FailedQuestToggle: View {
    let number: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.headline)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(isSelected ? (number == 0 ? Color.green : Color.red) : Color.gray.opacity(0.5))
                )
                .foregroundColor(.white)
                .padding(2)
        }
        .accessibilityLabel("\(number)\(isSelected ? " selected" : "")")
    }
}

#Preview {
    FailedQuestToggle(number: 0, isSelected: true) {}
}
