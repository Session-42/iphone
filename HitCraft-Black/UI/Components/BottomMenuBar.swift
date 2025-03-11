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
                    isSelected: selectedTab == .chat,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .chat
                    }
                )
                
                // History Button - second position
                MenuButton(
                    icon: "clock",
                    isSelected: selectedTab == .history,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .history
                    }
                )
                
                // Productions Button
                MenuButton(
                    icon: "music.note.list",
                    isSelected: selectedTab == .productions,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .productions
                    }
                )
                
                // Settings Button
                MenuButton(
                    icon: "gearshape",
                    isSelected: selectedTab == .settings,
                    selectedColor: selectedColor,
                    action: {
                        selectedTab = .settings
                    }
                )
            }
            .frame(height: 60)
            
            // Extra padding at the bottom that extends beyond safe area - DOUBLED FROM 10 TO 20
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 20)
                .edgesIgnoringSafeArea(.bottom)
        }
        .background(backgroundColor)
    }
}

struct MenuButton: View {
    let icon: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void
    
    // Light text color as specified
    private let textColor = Color(hex: "F5F4EF")
    
    var body: some View {
        Button(action: action) {
            // Just the icon, no text below it
            Image(systemName: icon)
                .font(.system(size: 24)) // Slightly larger icon since we removed text
                .foregroundColor(isSelected ? selectedColor : textColor)
                .padding(.vertical, 16) // Increased vertical padding to center in the bar
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .frame(maxWidth: .infinity) // Take up equal space
    }
}
