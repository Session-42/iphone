// File: HitCraft-Black/UI/Components/HCChatHistoryCard.swift

import SwiftUI

struct HCChatHistoryCard: View {
    let item: ChatItem
    let isExpanded: Bool
    let onTap: () -> Void
    let onLoadChat: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row with chat bubble
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    // Chat icon with gradient background
                    ZStack {
                        Circle()
                            .fill(HitCraftColors.accent.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "bubble.left.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(HitCraftColors.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // Title
                        Text(item.title)
                            .font(HitCraftFonts.body())
                            .foregroundColor(HitCraftColors.text)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Date
                        Text(formattedDate)
                            .font(HitCraftFonts.caption())
                            .foregroundColor(HitCraftColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Expand/collapse arrow
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(HitCraftColors.accent)
                        .padding(.top, 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details
            if isExpanded, let details = item.details {
                VStack(alignment: .leading, spacing: 8) {
                    // Only show divider if there are details
                    Rectangle()
                        .fill(HitCraftColors.border)
                        .frame(height: 1)
                    
                    // Details with leading icons
                    HStack(spacing: 10) {
                        Image(systemName: "music.note")
                            .foregroundColor(HitCraftColors.accent)
                        Text(details.pluginName)
                            .font(HitCraftFonts.caption())
                            .foregroundColor(HitCraftColors.secondaryText)
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .foregroundColor(HitCraftColors.accent)
                        Text(details.year)
                            .font(HitCraftFonts.caption())
                            .foregroundColor(HitCraftColors.secondaryText)
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "link")
                            .foregroundColor(HitCraftColors.accent)
                        Text(details.presetLink)
                            .font(HitCraftFonts.caption())
                            .foregroundColor(HitCraftColors.accent)
                    }
                    
                    // Open chat button with prominent styling
                    Button(action: onLoadChat) {
                        HStack {
                            Text("Continue this chat")
                                .font(HitCraftFonts.subheader())
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(HitCraftColors.primaryGradient)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 12)
            } else if !isExpanded {
                // When not expanded, show a subtle "Continue" button
                HStack {
                    Spacer()
                    
                    Button(action: onLoadChat) {
                        HStack(spacing: 5) {
                            Text("Continue")
                                .font(HitCraftFonts.caption())
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(HitCraftColors.accent)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 12)
                    }
                    .hitCraftStyle()
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HitCraftColors.cardBackground) // Now uses the updated cardBackground color
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
    
    // Format the date nicely
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let timeAgo = formatter.localizedString(for: item.date, relativeTo: Date())
        
        // Also add time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: item.date)
        
        return timeAgo + " at " + timeString
    }
}
