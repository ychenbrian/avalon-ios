import Observation
import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(\.injected) private var injected: DIContainer

    var body: some View {
        VStack {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 60))
                .padding()
            Text("Settings Screen")
                .font(.title)
        }
    }
}
