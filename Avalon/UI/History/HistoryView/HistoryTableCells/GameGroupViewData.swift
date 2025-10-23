import Foundation
import SwiftData
import SwiftUI

@Observable
final class GameGroupViewData {
    var games: [AvalonGame] = []
    var date: String

    init(games: [AvalonGame], date: String) {
        self.games = games
        self.date = date
    }
}
