// File: HitCraft-Black/Models/ChatHistoryModels.swift

import SwiftUI

// Models needed for HistoryView
struct ChatItem: Identifiable {
    let id = UUID()
    let title: String
    var details: ChatDetails?
    var threadId: String?
    var date: Date
    var previewMessage: String?
    var messageCount: Int?
    
    init(
        title: String,
        details: ChatDetails? = nil,
        threadId: String? = nil,
        date: Date = Date(),
        previewMessage: String? = nil,
        messageCount: Int? = nil
    ) {
        self.title = title
        self.details = details
        self.threadId = threadId
        self.date = date
        self.previewMessage = previewMessage
        self.messageCount = messageCount
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
