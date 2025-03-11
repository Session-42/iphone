import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
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
    }
}
