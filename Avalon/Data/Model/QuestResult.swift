import Foundation
import SwiftData
import SwiftUI

@Model
final class QuestResult {
    var id: UUID
    var type: ResultType?
    var failCount: Int

    init(id: UUID = UUID(), type: ResultType? = nil, failCount: Int = 0) {
        self.id = id
        self.type = type
        self.failCount = failCount
    }
}
