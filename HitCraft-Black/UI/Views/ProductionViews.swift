// File: HitCraft-Black/Views/ProductionsView.swift

import SwiftUI

struct ProductionsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScreenHeader(title: "PRODUCTIONS")
            
            // Content
            Text("Productions View")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(HitCraftColors.background)
    }
}
