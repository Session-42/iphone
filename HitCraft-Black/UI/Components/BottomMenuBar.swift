// File: HitCraft-Black/Views/BottomMenuBar.swift

import SwiftUI

struct BottomMenuBar: View {
    @Binding var selectedTab: MenuTab
    var onStartNewChat: () -> Void
    
    // Use the specific color you mentioned
    private let backgroundColor = Color(hex: "3d3c3a")
    
    var body: some View {
        HStack(spacing: 0) {
            // History Button
            MenuButton(
                icon: "clock",
                text: "History",
                isSelected: selectedTab == .history,
                action: {
                    selectedTab = .history
                }
            )
            
            // Chat Button
            MenuButton(
                icon: "message",
                text: "Chat",
                isSelected: selectedTab == .chat,
                action: {
                    // Check if current chat is less than 1 hour old
                    let lastChatTime = UserDefaults.standard.object(forKey: "lastChatTime") as? Date
                    let oneHourAgo = Date().addingTimeInterval(-3600) // 1 hour ago
                    
                    if let lastChatTime = lastChatTime, lastChatTime > oneHourAgo {
                        // Use existing chat
                        selectedTab = .chat
                    } else {
                        // Start new chat
                        onStartNewChat()
                        
                        // Save current time for next check
                        UserDefaults.standard.set(Date(), forKey: "lastChatTime")
                        
                        selectedTab = .chat
                    }
                }
            )
            
            // Productions Button
            MenuButton(
                icon: "music.note.list",
                text: "Productions",
                isSelected: selectedTab == .productions,
                action: {
                    selectedTab = .productions
                }
            )
            
            // Settings Button
            MenuButton(
                icon: "gearshape",
                text: "Settings",
                isSelected: selectedTab == .settings,
                action: {
                    selectedTab = .settings
                }
            )
        }
        .frame(height: 60)
        .background(backgroundColor)
        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: -1)
    }
}

struct MenuButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? HitCraftColors.accent : Color.gray.opacity(0.7))
                
                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? HitCraftColors.accent : Color.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
