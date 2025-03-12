import SwiftUI
import AVFoundation

// Model for reference options
struct ReferenceOption: Identifiable {
    let id: String
    let name: String
    let genre: String
    let imageURL: URL?
    let audioURL: URL?
}

// Reference Selection View
struct ReferenceSelectionView: View {
    let referenceId: String
    let referenceCandidatesId: String
    let selectedOptionNumber: Int
    
    // Mock data for now
    @State private var referenceOptions: [ReferenceOption] = [
        ReferenceOption(
            id: "option1",
            name: "Lo-fi Beats",
            genre: "Lo-fi Hip Hop",
            imageURL: URL(string: "https://example.com/lofi.jpg"),
            audioURL: URL(string: "https://example.com/lofi.mp3")
        ),
        ReferenceOption(
            id: "option2",
            name: "Ambient Chill",
            genre: "Ambient",
            imageURL: URL(string: "https://example.com/ambient.jpg"),
            audioURL: URL(string: "https://example.com/ambient.mp3")
        )
    ]
    
    @State private var isLoading = false
    @State private var audioPlayers: [String: AVAudioPlayer] = [:]
    @State private var playingOptionId: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select a Reference")
                .font(.headline)
                .foregroundColor(HitCraftColors.text)
                .padding(.bottom, 4)
            
            if isLoading {
                ProgressView("Loading references...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(referenceOptions) { option in
                    ReferenceOptionCard(
                        option: option,
                        isSelected: option.id == referenceOptions[selectedOptionNumber - 1].id,
                        isPlaying: playingOptionId == option.id,
                        onPlay: {
                            toggleAudio(for: option)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            // Simulating API fetch with a brief delay
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchReferenceOptions()
            }
        }
    }
    
    private func fetchReferenceOptions() {
        // In a real implementation, this would fetch data from your API
        // using the referenceId and referenceCandidatesId
        
        // For now, just finish the loading state with mock data
        isLoading = false
    }
    
    private func toggleAudio(for option: ReferenceOption) {
        // Stop any currently playing audio
        if let playingId = playingOptionId, let player = audioPlayers[playingId] {
            player.stop()
            
            // Only stop if we're toggling the same option
            if playingId == option.id {
                playingOptionId = nil
                return
            }
        }
        
        // Start playing the selected option
        playingOptionId = option.id
        
        // In a real implementation, this would create and play audio
        // But for the mock, we'll just toggle the state
        
        // Simulate stopping after a duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if playingOptionId == option.id {
                playingOptionId = nil
            }
        }
    }
}

// Card for each reference option
struct ReferenceOptionCard: View {
    let option: ReferenceOption
    let isSelected: Bool
    let isPlaying: Bool
    let onPlay: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Reference thumbnail
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                // Use a placeholder for now
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .cornerRadius(8)
            
            // Reference details
            VStack(alignment: .leading, spacing: 4) {
                Text(option.name)
                    .font(.headline)
                    .foregroundColor(HitCraftColors.text)
                
                Text(option.genre)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Play button
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? HitCraftColors.accent : Color.secondary.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .foregroundColor(isPlaying ? .white : HitCraftColors.accent)
                }
            }
        }
        .padding()
        .background(isSelected ? HitCraftColors.accent.opacity(0.1) : Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? HitCraftColors.accent : Color.clear, lineWidth: 2)
        )
    }
}