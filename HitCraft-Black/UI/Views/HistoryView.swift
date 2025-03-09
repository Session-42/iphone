// File: HitCraft-Black/UI/Views/HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @ObservedObject private var chatManager = ChatPersistenceManager.shared
    @State private var searchText = ""
    @State private var expandedCardId: UUID? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            ScreenHeader(title: "HISTORY")
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(HitCraftColors.secondaryText)
                TextField("Search chats...", text: $searchText)
                    .font(HitCraftFonts.body())
                    .foregroundColor(HitCraftColors.text)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(HitCraftColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(HitCraftColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .tint(HitCraftColors.accent)
                    .scaleEffect(1.5)
                    .padding()
                Spacer()
            } else if viewModel.chatItems.isEmpty {
                // No history items state
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(HitCraftColors.secondaryText.opacity(0.3))
                    
                    Text("No Chat History")
                        .font(HitCraftFonts.subheader())
                        .foregroundColor(HitCraftColors.text)
                    
                    Text("Start a conversation to see your chat history here")
                        .font(HitCraftFonts.body())
                        .foregroundColor(HitCraftColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Create New Chat Button
                    Button(action: {
                        startNewChat()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Start New Chat")
                        }
                        .padding()
                        .frame(width: 220)
                        .background(HitCraftColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .padding(.bottom, 40)
                }
            } else {
                // Chat history items
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredChatItems) { item in
                            // Using the renamed component HCChatHistoryCard
                            HCChatHistoryCard(
                                item: item,
                                isExpanded: expandedCardId == item.id,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        expandedCardId = expandedCardId == item.id ? nil : item.id
                                    }
                                },
                                onLoadChat: {
                                    loadChat(item: item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(HitCraftColors.historyBackground)
        .onAppear {
            viewModel.loadChatHistory()
        }
    }
    
    // Filter chat items based on search text
    private var filteredChatItems: [ChatItem] {
        if searchText.isEmpty {
            return viewModel.chatItems
        } else {
            return viewModel.chatItems.filter { item in
                item.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // Load a specific chat thread
    private func loadChat(item: ChatItem) {
        if let threadId = item.threadId {
            // Set the active thread ID in ChatService
            ChatService.shared.activeThreadId = threadId
            
            // Create continuation effect in the messages
            chatManager.clearChat()
            chatManager.prepareToLoadChatThread(threadId: threadId, title: item.title)
            
            // Switch to the chat tab
            NotificationCenter.default.post(
                name: NSNotification.Name("SwitchToTab"),
                object: nil,
                userInfo: ["tab": MenuTab.chat]
            )
        }
    }
    
    // Start a new chat
    private func startNewChat() {
        chatManager.clearChat()
        
        // Switch to the chat tab
        NotificationCenter.default.post(
            name: NSNotification.Name("SwitchToTab"),
            object: nil,
            userInfo: ["tab": MenuTab.chat]
        )
        
        // Trigger chat refresh
        NotificationCenter.default.post(
            name: NSNotification.Name("RefreshChat"),
            object: nil
        )
    }
}

// History View Model
class HistoryViewModel: ObservableObject {
    @Published var chatItems: [ChatItem] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let artistId = "67618ad67dc13643acff6a25" // Default artist ID
    
    func loadChatHistory() {
        isLoading = true
        
        // Simulate loading data with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Sample data - in a real app, this would come from an API
            self.chatItems = [
                ChatItem(
                    title: "Need help with my 2nd verse lyrics",
                    details: ChatDetails(
                        pluginName: "Songwriting",
                        year: "2025",
                        presetLink: "https://hitcraft.ai/presets/lyrics"
                    ),
                    threadId: "sample-thread-1",
                    date: Date().addingTimeInterval(-86400) // 1 day ago
                ),
                ChatItem(
                    title: "I need some help with good presets for kick drum sound",
                    details: ChatDetails(
                        pluginName: "12/07/92",
                        year: "2025",
                        presetLink: "https://hitcraft.ai/presets/kick"
                    ),
                    threadId: "sample-thread-2",
                    date: Date().addingTimeInterval(-259200) // 3 days ago
                ),
                ChatItem(
                    title: "Catchy drop ideas for EDM track",
                    details: ChatDetails(
                        pluginName: "EDM Production",
                        year: "2025",
                        presetLink: "https://hitcraft.ai/presets/edm"
                    ),
                    threadId: "sample-thread-3",
                    date: Date().addingTimeInterval(-345600) // 4 days ago
                ),
                ChatItem(
                    title: "Pop ballad production tips",
                    details: ChatDetails(
                        pluginName: "Pop Ballad",
                        year: "2025",
                        presetLink: "https://hitcraft.ai/presets/ballad"
                    ),
                    threadId: "sample-thread-4",
                    date: Date().addingTimeInterval(-604800) // 1 week ago
                ),
                ChatItem(
                    title: "Recommend the right tempo for my song",
                    details: ChatDetails(
                        pluginName: "Tempo Guide",
                        year: "2025",
                        presetLink: "https://hitcraft.ai/presets/tempo"
                    ),
                    threadId: "sample-thread-5",
                    date: Date().addingTimeInterval(-1209600) // 2 weeks ago
                )
            ]
            
            // Sort by most recent
            self.chatItems.sort { $0.date > $1.date }
            
            self.isLoading = false
        }
    }
}
