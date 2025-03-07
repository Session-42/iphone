// File: HitCraft-Black/Core/MainView.swift

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var authService: HCAuthService
    @State private var defaultArtist = ArtistProfile.sample
    
    var body: some View {
        VStack {
            Text("Welcome to Hitcraft!")
                .font(.largeTitle)
            
            Button("Logout") {
                Task {
                    await authService.logout()
                }
            }
            .padding()
            .background(HitCraftColors.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
            
            // Chat Section
            Button("Start Chat") {
                // For now, just print to ensure chat service is working
                Task {
                    do {
                        let message = try await ChatService.shared.sendMessage(
                            text: "Hello!",
                            artistId: defaultArtist.id
                        )
                        print("Response: \(message.content)")
                    } catch {
                        print("Chat error: \(error)")
                    }
                }
            }
            .padding()
            .background(HitCraftColors.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(HCAuthService.shared)
    }
}
