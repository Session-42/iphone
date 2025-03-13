import SwiftUI

// Create a loading view component
private struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(HitCraftColors.accent)
                .scaleEffect(1.5)
                .padding()
            Spacer()
        }
    }
}

// Create a chat list item component
private struct ChatListItem: View {
    let thread: ChatThread
    let isExpanded: Bool
    let onTap: () -> Void
    let chatManager: ChatPersistenceManager
    
    var body: some View {
        HCChatHistoryCard(
            item: thread,
            isExpanded: isExpanded,
            onTap: onTap,
            onLoadChat: {
                Task {
                    await chatManager.prepareToLoadChatThread(threadId: thread.id)
                    
                    // Switch to chat tab
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SwitchToTab"),
                        object: nil,
                        userInfo: ["tab": MenuTab.chat]
                    )
                }
            }
        )
    }
}

// Create a chat list component
private struct ChatListView: View {
    let threads: [ChatThread]
    let expandedCardId: String?
    let onCardTap: (ChatThread) -> Void
    let chatManager: ChatPersistenceManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(threads) { thread in
                    ChatListItem(
                        thread: thread,
                        isExpanded: expandedCardId == thread.id,
                        onTap: { onCardTap(thread) },
                        chatManager: chatManager
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @ObservedObject private var chatManager = ChatPersistenceManager.shared
    @State private var searchText = ""
    @State private var expandedCardId: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "HISTORY")
            SearchBarView(searchText: $searchText)
            
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.chatThreads.isEmpty {
                EmptyHistoryStateView(onStartNewChat: startNewChat)
            } else {
                ChatListView(
                    threads: viewModel.chatThreads,
                    expandedCardId: expandedCardId,
                    onCardTap: { thread in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedCardId = expandedCardId == thread.id ? nil : thread.id
                        }
                    },
                    chatManager: chatManager
                )
                .refreshable {
                    await viewModel.refreshChatThreads()
                }
            }
        }
        .background(HitCraftColors.historyBackground)
        .onAppear {
            viewModel.loadChatThreads()
        }
    }
    
    private func startNewChat() {
        Task {
            await chatManager.initializeChat(artistId: Constants.Artist.defaultId)
            NotificationCenter.default.post(
                name: NSNotification.Name("SwitchToTab"),
                object: nil,
                userInfo: ["tab": MenuTab.chat]
            )
        }
    }
}

class HistoryViewModel: ObservableObject {
    @Published var chatThreads: [ChatThread] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let chatService = ChatService.shared
    
    func loadChatThreads() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                let response = try await chatService.listChats(amount: 20)
                
                // Convert dictionary to array of ChatThread
                let threads = response.threads.map { id, data in
                    ChatThread(id: id, data: data)
                }
                
                await MainActor.run {
                    self.chatThreads = threads.sorted(by: { $0.lastMessageAt > $1.lastMessageAt })
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load chat history: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("Error loading chat threads: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshChatThreads() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await chatService.listChats(amount: 20)
            
            // Convert dictionary to array of ChatThread
            let threads = response.threads.map { id, data in
                ChatThread(id: id, data: data)
            }
            
            await MainActor.run {
                self.chatThreads = threads.sorted(by: { $0.lastMessageAt > $1.lastMessageAt })
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to refresh chat history: \(error.localizedDescription)"
                self.isLoading = false
            }
            print("Error refreshing chat threads: \(error.localizedDescription)")
        }
    }
}
