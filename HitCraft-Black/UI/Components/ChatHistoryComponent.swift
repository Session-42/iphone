// File: HitCraft-Black/UI/Components/ChatHistoryComponents.swift

import SwiftUI

// ChatHistoryCard component for both HistoryView and ChatSummaryView
struct ChatHistoryCardView: View {
    let item: ChatItem
    let isExpanded: Bool
    let onTap: () -> Void
    let onLoadChat: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row with chat bubble
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "bubble.left.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(HitCraftColors.accent.opacity(0.6))
                    
                    Text(item.title)
                        .font(HitCraftFonts.body())
                        .foregroundColor(HitCraftColors.text)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded details
            if isExpanded, let details = item.details {
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(title: "Plugin name", value: details.pluginName)
                    DetailRow(title: "Year", value: details.year)
                    DetailRow(title: "link to preset", value: details.presetLink, isLink: true)
                    
                    Button(action: onLoadChat) {
                        HStack {
                            Text("Take me to this Chat")
                                .font(HitCraftFonts.poppins(14, weight: .medium))
                                .foregroundColor(HitCraftColors.accent)
                            Image(systemName: "arrow.right")
                                .foregroundColor(HitCraftColors.accent)
                        }
                    }
                    .padding(.top, 4)
                    .hitCraftStyle()
                }
                .padding(.leading, 32)
            } else if !isExpanded {
                // Always show a "Go to Chat" button even when not expanded
                Button(action: onLoadChat) {
                    Text("Open chat")
                        .font(HitCraftFonts.caption())
                        .foregroundColor(HitCraftColors.accent)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(HitCraftColors.accent.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.leading, 32)
                .hitCraftStyle()
            }
        }
        .padding(.vertical, 19)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HitCraftColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: HitCraftLayout.cardCornerRadius)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(themeManager.currentTheme == .dark ? 0.2 : 0.05), radius: 2, x: 0, y: 1)
    }
}

// DetailRow component used in the ChatHistoryCardView
struct DetailRow: View {
    let title: String
    let value: String
    var isLink: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title + ":")
                .font(HitCraftFonts.poppins(14, weight: .medium))
                .foregroundColor(HitCraftColors.secondaryText)
                .frame(width: 100, alignment: .leading)
            
            if isLink {
                Button(action: {
                    if let url = URL(string: value) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text(value)
                        .font(HitCraftFonts.poppins(14))
                        .foregroundColor(HitCraftColors.accent)
                        .underline()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Text(value)
                    .font(HitCraftFonts.poppins(14))
                    .foregroundColor(HitCraftColors.text)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// Also define ChatHistoryCard as an alias to ChatHistoryCardView for backward compatibility
typealias ChatHistoryCard = ChatHistoryCardView
