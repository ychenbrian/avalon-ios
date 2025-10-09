import Observation
import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    @Environment(\.injected) private var injected: DIContainer

    var body: some View {
        VStack {
            Image(systemName: "clock.fill")
                .font(.system(size: 60))
                .padding()
            Text("History Screen")
                .font(.title)
        }
    }
}
