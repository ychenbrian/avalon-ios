import Foundation

protocol PreferencesInteractor {
    func fetchPreferences() -> UserPreferences
    func updateDarkMode(enabled: Bool) -> UserPreferences
}

struct RealPreferencesInteractor: PreferencesInteractor {
    private let repository: PreferencesRepository

    init(repository: PreferencesRepository) {
        self.repository = repository
    }

    func fetchPreferences() -> UserPreferences {
        repository.load()
    }

    func updateDarkMode(enabled: Bool) -> UserPreferences {
        var current = repository.load()
        current.isDarkModeEnabled = enabled
        repository.save(current)
        return current
    }
}

final class StubPreferencesInteractor: PreferencesInteractor {
    func fetchPreferences() -> UserPreferences {
        UserPreferences(isDarkModeEnabled: false)
    }

    func updateDarkMode(enabled: Bool) -> UserPreferences {
        UserPreferences(isDarkModeEnabled: enabled)
    }
}
