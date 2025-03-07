// File: HitCraft-Black/Core/Authentication/Views/LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: HCAuthService
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                HitCraftColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(HitCraftColors.accent)
                        .padding(.bottom, 20)
                    
                    Text("Welcome to Hitcraft")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(HitCraftColors.text)
                    
                    Text("Sign in to continue")
                        .font(.title3)
                        .foregroundColor(HitCraftColors.secondaryText)
                    
                    Spacer()
                    
                    Button(action: {
                        isLoading = true
                        authService.startAuthFlow()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isLoading ? "Signing in..." : "Sign In")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isLoading ? HitCraftColors.accent.opacity(0.8) : HitCraftColors.accent)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    
                    VStack(spacing: 10) {
                        Text("Don't have an account?")
                            .foregroundColor(HitCraftColors.secondaryText)
                        
                        Button(action: {
                            if let url = URL(string: "https://hitcraft.ai/sign-up") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Create one here")
                                .foregroundColor(HitCraftColors.accent)
                                .underline()
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onChange(of: authService.isAuthenticated) { newValue in
            if newValue {
                isLoading = false
            }
        }
        .preferredColorScheme(.dark) // Force dark mode
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(HCAuthService.shared)
            .preferredColorScheme(.dark)
    }
}
