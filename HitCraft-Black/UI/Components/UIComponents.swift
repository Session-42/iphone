// File: HitCraft-Black/UI/Components/UIComponents.swift

import SwiftUI

// Standard screen header
struct ScreenHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(HitCraftFonts.header())
                .foregroundColor(HitCraftColors.text)
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .background(HitCraftColors.headerFooterBackground)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
