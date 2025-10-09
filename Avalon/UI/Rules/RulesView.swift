import Observation
import SwiftUI

struct RulesView: View {
    @State private var viewModel = RulesViewModel()
    @Environment(\.injected) private var injected: DIContainer

    var body: some View {
        VStack {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .padding()
            Text("Rules Screen")
                .font(.title)
        }
    }
}
