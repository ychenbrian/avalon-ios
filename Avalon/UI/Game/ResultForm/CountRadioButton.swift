import SwiftUI

struct CountRadioButton: View {
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
                .padding(2)
        }
        .accessibilityLabel("\(name) failed quests\(isSelected ? " selected" : "")")
    }
}

#Preview {
    HStack {
        ForEach(0 ..< 5) { i in
            CountRadioButton(name: "\(i)", isSelected: [true, false].randomElement()!, selectedColor: [Color.green, Color.red].randomElement()!, action: {})
        }
    }
}
