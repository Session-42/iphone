import SwiftUI

struct HCChatHistoryCard: View {
    let item: ChatThread
    let isExpanded: Bool
    let onTap: () -> Void
    let onLoadChat: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(HitCraftFonts.subheader())
                            .foregroundColor(HitCraftColors.text)
                            .lineLimit(1)
                        
                        Text("Artist ID: \(item.artistId)")
                            .font(HitCraftFonts.caption())
                            .foregroundColor(HitCraftColors.secondaryText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(formattedDate(item.lastMessageAt))
                            .font(HitCraftFonts.caption())
                            .foregroundColor(HitCraftColors.secondaryText)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(HitCraftColors.secondaryText)
                            .padding(.top, 15)
                    }
                }
                .padding()
                .background(HitCraftColors.cardBackground)
                .cornerRadius(isExpanded ? 15 : 15)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                    .background(HitCraftColors.border)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    Button(action: onLoadChat) {
                        HStack {
                            Image(systemName: "bubble.left.fill")
                            Text("Open Chat")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(HitCraftColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(HitCraftColors.cardBackground)
                .cornerRadius(15)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(HitCraftColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Format the date for display
    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}