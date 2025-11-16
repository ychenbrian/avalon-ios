import Observation
import SwiftUI

struct SettingsView: View {
    @StateObject private var presenter: PreferencesPresenter

    init(interactor: PreferencesInteractor,
         themeManager: ThemeManager)
    {
        _presenter = StateObject(
            wrappedValue: PreferencesPresenter(
                interactor: interactor,
                themeManager: themeManager
            )
        )
    }

    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: Binding(
                get: { presenter.isDarkModeEnabled },
                set: { presenter.setDarkMode($0) }
            ))
        }
        .navigationTitle("Settings")
        .onAppear { presenter.onAppear() }
    }
}
