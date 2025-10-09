import SwiftData
import SwiftUI

struct DIContainer {
    let appState: Store<AppState>
    let interactors: Interactors

    init(appState: Store<AppState> = .init(AppState()), interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }

    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }
}

extension DIContainer {
    struct WebRepositories {
        let images: ImagesWebRepository
    }

    struct Interactors {
        let images: ImagesInteractor
        let userPermissions: UserPermissionsInteractor

        static var stub: Self {
            .init(images: StubImagesInteractor(),
                  userPermissions: StubUserPermissionsInteractor())
        }
    }
}

extension EnvironmentValues {
    @Entry var injected: DIContainer = .init(appState: AppState(), interactors: .stub)
}

extension View {
    func inject(_ container: DIContainer) -> some View {
        return environment(\.injected, container)
    }
}
