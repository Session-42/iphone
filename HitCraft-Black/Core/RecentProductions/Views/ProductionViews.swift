// File: HitCraft-Black/UI/Views/ProductionsView.swift

import SwiftUI

struct ProductionsView: View {
    // Renamed ViewModel to avoid conflicts
    @StateObject private var viewModel = HCProductionsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ScreenHeader(title: "RECENT PRODUCTIONS")
            
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    // Loading indicator
                    Spacer()
                    LoadingIndicator()
                    Spacer()
                } else if viewModel.error != nil {
                    // Error state
                    Spacer()
                    ErrorView(message: viewModel.error?.localizedDescription ?? "Failed to load productions")
                    Spacer()
                } else if viewModel.productions.isEmpty {
                    // Empty state
                    Spacer()
                    EmptyView(message: "No productions found")
                    Spacer()
                } else {
                    // List of productions
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.productions) { production in
                                ProductionCard(
                                    production: production,
                                    onDownload: { url, filename in
                                        viewModel.downloadProduction(url: url, fileName: filename)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .background(HitCraftColors.historyBackground)
        .onAppear {
            viewModel.loadData()
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

// Loading indicator component
struct LoadingIndicator: View {
    var body: some View {
        VStack {
            // Create a spinner similar to the web version
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "8a44c8"), // First color
                            Color(hex: "df0c39")  // Second color
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(360))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
            
            Text("Loading productions...")
                .font(HitCraftFonts.caption())
                .foregroundColor(HitCraftColors.secondaryText)
                .padding(.top, 8)
        }
    }
}

// Error view component
struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "df0c39"))
            
            Text(message)
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Try Again") {
                NotificationCenter.default.post(name: NSNotification.Name("RefreshProductions"), object: nil)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(HitCraftColors.accent)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

// Empty state view component
struct EmptyView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(HitCraftColors.secondaryText.opacity(0.5))
            
            Text(message)
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.secondaryText)
            
            Button("Create Your First Production") {
                NotificationCenter.default.post(
                    name: NSNotification.Name("SwitchToTab"),
                    object: nil,
                    userInfo: ["tab": MenuTab.chat]
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(HitCraftColors.accent)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
