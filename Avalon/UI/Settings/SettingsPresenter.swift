import Foundation

@MainActor
final class PreferencesPresenter: ObservableObject {
    @Published var isDarkModeEnabled: Bool = false

    private let interactor: PreferencesInteractor
    private let themeManager: ThemeManager

    init(interactor: PreferencesInteractor,
         themeManager: ThemeManager)
    {
        self.interactor = interactor
        self.themeManager = themeManager
    }

    func onAppear() {
        let prefs = interactor.fetchPreferences()
        apply(prefs)
    }

    func setDarkMode(_ enabled: Bool) {
        let prefs = interactor.updateDarkMode(enabled: enabled)
        apply(prefs)
    }

    private func apply(_ prefs: UserPreferences) {
        isDarkModeEnabled = prefs.isDarkModeEnabled
        themeManager.isDarkMode = prefs.isDarkModeEnabled
    }
}
