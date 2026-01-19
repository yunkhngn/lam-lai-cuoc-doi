//
//  Item.swift
//  Làm lại cuộc đời
//
//  Created by Khoa Nguyễn on 19/01/2026.
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
