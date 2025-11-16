import Combine
import SwiftUI

struct AppState: Equatable {
    var routing = ViewRouting()
    var system = System()
    var permissions = Permissions()
}

extension AppState {
    enum Tab: Hashable {
        case game
        case history
        case rules
        case settings
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var selectedTab: Tab = .game

        var gameView = GameView.Routing()
        var historyView = HistoryView.Routing()

        var playerView = PlayerView.Routing()
        var gameDetailsView = GameDetailsView.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
        var keyboardHeight: CGFloat = 0
    }
}

extension AppState {
    struct Permissions: Equatable {
        var push: Permission.Status = .unknown
    }

    static func permissionKeyPath(for permission: Permission) -> WritableKeyPath<AppState, Permission.Status> {
        let pathToPermissions = \AppState.permissions
        switch permission {
        case .pushNotifications:
            return pathToPermissions.appending(path: \.push)
        }
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.routing == rhs.routing
        && lhs.system == rhs.system
}
