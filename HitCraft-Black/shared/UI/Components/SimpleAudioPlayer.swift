// File: HitCraft-Black/UI/Components/SimpleAudioPlayer.swift

import SwiftUI

struct SimpleAudioPlayer: View {
    let audioUrl: String
    
    @State private var isPlaying = false
    @State private var isLoading = false
    @State private var progress: CGFloat = 0.0
    
    // Timer for simulating playback progress
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar with indicator
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color(hex: "F1F1F1").opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Progress indicator
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: max(0, progress) * UIScreen.main.bounds.width * 0.6, height: 4)
                    .cornerRadius(2)
                
                // Progress handle
                Circle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 10, height: 10)
                    .offset(x: (max(0, progress) * UIScreen.main.bounds.width * 0.6) - 5)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .frame(height: 10)
            .padding(.vertical, 4)
            
            // Play/Pause controls
            HStack {
                // Play/Pause button
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HitCraftColors.accent)
                        .frame(width: 24, height: 24)
                }
                .disabled(isLoading)
                
                // Time label
                Text(formatTimeFromProgress(progress))
                    .font(.system(size: 10))
                    .foregroundColor(HitCraftColors.secondaryText)
                    .frame(width: 50, alignment: .leading)
            }
            .padding(.leading, 4)
        }
        .onDisappear {
            // Clean up timer when view disappears
            stopPlayback()
        }
    }
    
    // Toggle play/pause state
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    // Start playback with progress simulation
    private func startPlayback() {
        isLoading = true
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            isPlaying = true
            
            // Start progress timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if progress < 1.0 {
                    progress += 0.001
                } else {
                    stopPlayback()
                    progress = 0.0
                }
            }
        }
    }
    
    // Stop playback and reset timer
    private func stopPlayback() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    // Format the time string from progress value
    private func formatTimeFromProgress(_ progress: CGFloat) -> String {
        // Assuming a typical song length of 3:30
        let totalSeconds = 210 * progress
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    SimpleAudioPlayer(audioUrl: "example.mp3")
        .padding()
        .frame(width: 250)
        .background(HitCraftColors.cardBackground)
}
