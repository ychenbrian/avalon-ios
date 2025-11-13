import SwiftUI

struct PlayerCircle: View {
    let name: String
    let filledColor: Color

    var body: some View {
        TextCircle(
            name: name,
            size: 40,
            filledColor: filledColor
        )
        .padding(2)
    }
}

#Preview {
    PlayerCircle(name: "1", filledColor: .appColor(.failColor))
}
