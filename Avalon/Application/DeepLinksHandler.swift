import Foundation

enum DeepLink: Equatable {
    case showGameResult(gameBase64: String)

    init?(url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == "www.example.com",
            let query = components.queryItems
        else { return nil }
        if let item = query.first(where: { $0.name == "game" }),
           let gameBase64 = item.value
        {
            self = .showGameResult(gameBase64: gameBase64)
            return
        }
        return nil
    }
}

// MARK: - DeepLinksHandler

@MainActor
protocol DeepLinksHandler {
    func open(deepLink: DeepLink)
}

struct RealDeepLinksHandler: DeepLinksHandler {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func open(deepLink: DeepLink) {
        switch deepLink {
        case let .showGameResult(gameBase64):
            let routeToDestination = {
                self.container.appState.bulkUpdate {
                    $0
                }
            }
            /*
             SwiftUI is unable to perform complex navigation involving
             simultaneous dismissal or older screens and presenting new ones.
             A work around is to perform the navigation in two steps:
             */
            let defaultRouting = AppState.ViewRouting()
            if container.appState.value.routing != defaultRouting {
                container.appState[\.routing] = defaultRouting
                let delay: DispatchTime = .now() + (ProcessInfo.processInfo.isRunningTests ? 0 : 1.5)
                DispatchQueue.main.asyncAfter(deadline: delay, execute: routeToDestination)
            } else {
                routeToDestination()
            }
        }
    }
}
