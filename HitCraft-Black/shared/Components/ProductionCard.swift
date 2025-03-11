// File: HitCraft-Black/UI/Components/ProductionCard.swift

import SwiftUI

struct ProductionCard: View {
    let production: Production
    let onDownload: (String, String) -> Void
    
    @State private var productionImage: URL? = nil
    @State private var isLoadingImage = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Album Image
                ZStack {
                    if let imageUrl = productionImage {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(HitCraftColors.secondaryText.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fill)
                                    .cornerRadius(16)
                                    .overlay(
                                        ProgressView()
                                            .tint(HitCraftColors.accent)
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                            case .failure:
                                Rectangle()
                                    .fill(HitCraftColors.secondaryText.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(HitCraftColors.secondaryText.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                            }
                        }
                        .frame(width: 80, height: 80)
                    } else if isLoadingImage {
                        // Loading state
                        Rectangle()
                            .fill(HitCraftColors.secondaryText.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .cornerRadius(16)
                            .overlay(
                                ProgressView()
                                    .tint(HitCraftColors.accent)
                            )
                    } else {
                        // Default image when none is available
                        Rectangle()
                            .fill(genreColor(production.genre))
                            .frame(width: 80, height: 80)
                            .cornerRadius(16)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .frame(width: 80, height: 80)
                
                // Content Column
                VStack(alignment: .leading, spacing: 0) {
                    // Top row with track info and download button
                    HStack {
                        // Track Info
                        VStack(alignment: .leading, spacing: 2) {
                            // Song Name
                            Text(production.songName)
                                .font(HitCraftFonts.subheader())
                                .foregroundColor(HitCraftColors.text)
                                .lineLimit(1)
                            
                            // Genre
                            Text(production.genre)
                                .font(.system(size: 12))
                                .foregroundColor(HitCraftColors.secondaryText)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Download Button
                        Button(action: {
                            onDownload(production.audioUrl, "\(production.songName).mp3")
                        }) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 16))
                                .foregroundColor(HitCraftColors.text)
                                .frame(width: 16, height: 20)
                        }
                        .hitCraftStyle()
                    }
                    .padding(.bottom, 12)
                    
                    // Audio Player
                    SimpleAudioPlayer(audioUrl: production.audioUrl)
                }
            }
            .padding(16)
        }
        .background(HitCraftColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 2)
        .onAppear {
            loadProductionImage()
        }
    }
    
    // Load the production image from the API
    private func loadProductionImage() {
        // If we already have a reference image URL, use it
        if let referenceUrl = production.referenceImageUrl, let url = URL(string: referenceUrl) {
            productionImage = url
            return
        }
        
        // Otherwise fetch from the API
        isLoadingImage = true
        
        Task {
            do {
                let imageUrl = try await ProductionsService.shared.getProductionImage(productionId: production._id)
                
                await MainActor.run {
                    productionImage = imageUrl
                    isLoadingImage = false
                }
            } catch {
                await MainActor.run {
                    isLoadingImage = false
                }
            }
        }
    }
    
    // Generate a color based on music genre
    private func genreColor(_ genre: String) -> Color {
        let genreLower = genre.lowercased()
        
        if genreLower.contains("pop") {
            return Color(hex: "FF5678") // Pink
        } else if genreLower.contains("rock") {
            return Color(hex: "E74C3C") // Red
        } else if genreLower.contains("hip") || genreLower.contains("rap") {
            return Color(hex: "9B59B6") // Purple
        } else if genreLower.contains("electronic") || genreLower.contains("edm") || genreLower.contains("dance") {
            return Color(hex: "3498DB") // Blue
        } else if genreLower.contains("r&b") || genreLower.contains("soul") {
            return Color(hex: "F39C12") // Orange
        } else if genreLower.contains("jazz") {
            return Color(hex: "2ECC71") // Green
        } else if genreLower.contains("classical") {
            return Color(hex: "34495E") // Dark Blue
        } else {
            return HitCraftColors.accent // Default to app accent color
        }
    }
}
