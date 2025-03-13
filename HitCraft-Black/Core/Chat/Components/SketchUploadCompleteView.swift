import SwiftUI

struct SketchUploadCompleteView: View {
    let taskId: String
    let sketchId: String
    let sketchUploadRequestId: String
    let songName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(HitCraftColors.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upload Complete")
                        .font(HitCraftFonts.body())
                        .foregroundColor(HitCraftColors.text)
                    
                    Text(songName)
                        .font(HitCraftFonts.caption())
                        .foregroundColor(HitCraftColors.secondaryText)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(HitCraftColors.accent)
                
                Text("Ready for processing")
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