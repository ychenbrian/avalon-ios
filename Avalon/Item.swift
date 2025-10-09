//
//  Item.swift
//  avalon-ios
//
//  Created by YUYU CHEN on 21/06/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
