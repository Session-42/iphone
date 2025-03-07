// File: HitCraft-Black/Views/HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var expandedCardId: UUID? = nil
    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Sample chat items - these would come from your API in a real app
    private let chatItems = [
        ChatItem(
            title: "Need help with my 2nd verse lyrics",
            threadId: "sample-thread-1"
        ),
        ChatItem(
            title: "I need some help with good presets for kick drum sound",
            details: ChatDetails(
                pluginName: "12/07/92",
                year: "2003",
                presetLink: "https://knightsoftheedit..."
            ),
            threadId: "sample-thread-2"
        ),
        ChatItem(title: "Catchy drop ideas", threadId: "sample-thread-3"),
        ChatItem(title: "Pop ballad production", threadId: "sample-thread-4"),
        ChatItem(title: "Recommend the right tempo for my song", threadId: "sample-thread-5")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            ScreenHeader(title: "HISTORY")
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(HitCraftColors.secondaryText)
                TextField("Search chats...", text: $searchText)
                    .font(HitCraftFonts.body())
                    .foregroundColor(HitCraftColors.text)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(HitCraftColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(HitCraftColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // List will go here once we have the ChatHistoryCardView component
            Text("History View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(HitCraftColors.background)
    }
}
