// File: HitCraft-Black/Models/ChatHistoryModels.swift

import SwiftUI

// Models needed for HistoryView
struct ChatItem: Identifiable {
    let id = UUID()
    let title: String
    var details: ChatDetails?
    var threadId: String?
    
    init(title: String, details: ChatDetails? = nil, threadId: String? = nil) {
        self.title = title
        self.details = details
        self.threadId = threadId
    }
}

struct ChatDetails {
    let pluginName: String
    let year: String
    let presetLink: String
    
    init(pluginName: String, year: String, presetLink: String) {
        self.pluginName = pluginName
        self.year = year
        self.presetLink = presetLink
    }
}
