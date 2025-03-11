// File: HitCraft-Black/Views/SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: HCAuthService
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScreenHeader(title: "SETTINGS")
            
            Spacer()
            
            // Logout Button
            Button(action: {
                Task {
                    await authService.logout()
                }
            }) {
                Text("Log Out")
                    .font(HitCraftFonts.subheader())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HitCraftColors.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            Spacer()
        }
        .background(HitCraftColors.background)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
    }
}
