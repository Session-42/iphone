import SwiftUI
import AVKit

struct SongRenderingView: View {
    let taskId: String
    let sketchId: String
    let butcherId: String
    
    // Mock data - in the future, this would be fetched from an API
    private let mockSongTitle = "Your Produced Song"
    private let mockArtistName = "AI Composer"
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 180 // Mock 3 minute song
    @State private var currentTime: Double = 0
    
    // Timer for updating progress
    @State private var timer: Timer?
    
    // Audio player (mock for now)
    @State private var audioPlayer: AVAudioPlayer?
    
    // In a real implementation, this would fetch the actual URL from an API
    private func getAudioUrl() -> URL? {
        // This is a mock URL - in the future, we would use the butcherId to fetch the real URL
        // return URL(string: "https://api.example.com/audio/\(butcherId)")
        
        // For now, we'll just use a bundle resource if available
        return Bundle.main.url(forResource: "sample", withExtension: "mp3")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "music.note")
                    .font(.system(size: 40))
                    .foregroundColor(HitCraftColors.accent)
                    .padding(.trailing, 8)
                
                VStack(alignment: .leading) {
                    Text(mockSongTitle)
                        .font(HitCraftFonts.header())
                        .foregroundColor(HitCraftColors.text)
                    
                    Text(mockArtistName)
                        .font(HitCraftFonts.caption())
                        .foregroundColor(HitCraftColors.text.opacity(0.7))
                }
                
                Spacer()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(HitCraftColors.accent)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
            
            // Time indicator
            HStack {
                Text(formatTime(currentTime))
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.text.opacity(0.7))
                
                Spacer()
                
                Text(formatTime(duration))
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.text.opacity(0.7))
            }
            
            // Playback controls
            HStack(spacing: 20) {
                Spacer()
                
                Button(action: {
                    // Go back 10 seconds
                    seekBackward()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 24))
                        .foregroundColor(HitCraftColors.text)
                }
                
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(HitCraftColors.accent)
                }
                
                Button(action: {
                    // Skip forward 10 seconds
                    seekForward()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 24))
                        .foregroundColor(HitCraftColors.text)
                }
                
                Spacer()
            }
            
            // Debug info (can be removed in production)
            VStack(alignment: .leading, spacing: 4) {
                Text("Task ID: \(taskId)")
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.text.opacity(0.5))
                
                Text("Sketch ID: \(sketchId)")
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.text.opacity(0.5))
                
                Text("Butcher ID: \(butcherId)")
                    .font(HitCraftFonts.caption())
                    .foregroundColor(HitCraftColors.text.opacity(0.5))
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            setupAudio()
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    // Format seconds into MM:SS format
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // Setup audio player
    private func setupAudio() {
        // In a real implementation, we would fetch the audio URL from an API
        // For now, we'll mock it
        if let audioUrl = getAudioUrl() {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                audioPlayer?.prepareToPlay()
                duration = audioPlayer?.duration ?? 180
            } catch {
                print("Error setting up audio player: \(error)")
            }
        }
    }
    
    // Toggle play/pause
    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    // Start playback
    private func startPlayback() {
        isPlaying = true
        audioPlayer?.play()
        
        // Create a timer to update progress
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = audioPlayer {
                currentTime = player.currentTime
                progress = player.currentTime / player.duration
                
                // Check if playback is complete
                if player.currentTime >= player.duration {
                    stopPlayback()
                }
            }
        }
    }
    
    // Pause playback
    private func pausePlayback() {
        isPlaying = false
        audioPlayer?.pause()
        timer?.invalidate()
        timer = nil
    }
    
    // Stop playback
    private func stopPlayback() {
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        progress = 0
        currentTime = 0
        timer?.invalidate()
        timer = nil
    }
    
    // Seek forward 10 seconds
    private func seekForward() {
        if let player = audioPlayer {
            let newTime = min(player.duration, player.currentTime + 10)
            player.currentTime = newTime
            currentTime = newTime
            progress = newTime / player.duration
        }
    }
    
    // Seek backward 10 seconds
    private func seekBackward() {
        if let player = audioPlayer {
            let newTime = max(0, player.currentTime - 10)
            player.currentTime = newTime
            currentTime = newTime
            progress = newTime / player.duration
        }
    }
}