// File: HitCraft-Black/UI/Components/BottomMenuBar.swift

import SwiftUI

struct BottomMenuBar: View {
    @Binding var selectedTab: MenuTab
    var onStartNewChat: () -> Void
    
    // Use the specific color
    private let backgroundColor = Color(hex: "3d3c3a")
    private let selectedColor = Color(hex: "d6307a") // Updated accent color
    
    var body: some View {
        VStack(spacing: 0) {
            // Main menu bar with proper height
            HStack(spacing: 0) {
                // Chat Button - first position
                MenuButton(
                    icon: "message",
                    text: "Chat",
                    isSelected: selectedTab == .chat,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .chat
                    }
                )
                
                // History Button - second position
                MenuButton(
                    icon: "clock",
                    text: "History",
                    isSelected: selectedTab == .history,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .history
                    }
                )
                
                // Productions Button
                MenuButton(
                    icon: "music.note.list",
                    text: "Productions",
                    isSelected: selectedTab == .productions,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .productions
                    }
                )
                
                // Settings Button
                MenuButton(
                    icon: "gearshape",
                    text: "Settings",
                    isSelected: selectedTab == .settings,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .settings
                    }
                )
            }
            .frame(height: 60)
            
            // Extra padding at the bottom that extends beyond safe area
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 10)
                .edgesIgnoringSafeArea(.bottom)
        }
        .background(backgroundColor)
    }
}

struct MenuButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void
    
    // Light text color as specified
    private let textColor = Color(hex: "F5F4EF")
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon positioned properly - not too high
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? selectedColor : textColor)
                    .padding(.top, 6)
                
                // Text with consistent spacing
                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? selectedColor : textColor)
                    .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
