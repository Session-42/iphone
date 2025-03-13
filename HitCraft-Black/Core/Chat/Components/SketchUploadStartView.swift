import SwiftUI

struct SketchUploadStartView: View {
    let taskId: String
    let fileName: String
    let sketchUploadRequestId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(HitCraftColors.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Uploading Sketch")
                        .font(HitCraftFonts.body())
                        .foregroundColor(HitCraftColors.text)
                    
                    Text(fileName)
                        .font(HitCraftFonts.caption())
                        .foregroundColor(HitCraftColors.secondaryText)
                }
            }
            
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: HitCraftColors.accent))
                    .scaleEffect(0.8)
                
                Text("Processing...")
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.secondaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(HitCraftColors.systemMessageBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HitCraftColors.accent.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 