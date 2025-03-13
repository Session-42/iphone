import SwiftUI
import WebKit

struct MessageBubble: View, Equatable {
    let associatedMessage: MessageData
    
    // Add Equatable conformance
    static func == (lhs: MessageBubble, rhs: MessageBubble) -> Bool {
        lhs.associatedMessage.id == rhs.associatedMessage.id
    }
    
    // Use a constant size instead of computing it repeatedly
    private let messagePadding = HitCraftLayout.messagePadding
    private let bubbleRadius = HitCraftLayout.messageBubbleRadius
    
    // Cache computed values
    private let messageContents: [MessageContentView]
    private let isSingleLine: Bool
    private let isAssistantMessage: Bool
    
    init(associatedMessage: MessageData) {
        self.associatedMessage = associatedMessage
        
        // Process all content types and wrap in a view model
        var contentViews: [MessageContentView] = []
        var textCount = 0
        
        for content in associatedMessage.content {
            switch content {
            case .text(let text):
                if !text.isEmpty {
                    contentViews.append(.text(text))
                    textCount += 1
                }
            case .sketch_upload_request(let id, let process):
                contentViews.append(.sketchUpload(id: id, process: process))
            case .sketch_upload_complete(let sketchId, let sketchUploadRequestId):
                contentViews.append(.sketchUploadComplete(
                    sketchId: sketchId,
                    sketchUploadRequestId: sketchUploadRequestId
                ))
            case .reference_selection(let referenceId, let candidatesId, let optionNumber):
                contentViews.append(.referenceSelection(
                    referenceId: referenceId, 
                    candidatesId: candidatesId, 
                    optionNumber: optionNumber
                ))
            case .song_rendering_complete(let taskId, let sketchId, let butcherId):
                contentViews.append(.songRendering(taskId: taskId, sketchId: sketchId, butcherId: butcherId))
            case .unknown:
                break
            }
        }
        
        self.messageContents = contentViews
        
        // Only consider it a single line if there's just one text content and it's short
        let onlyText = contentViews.count == 1 && contentViews.first?.isText == true
        if onlyText, case .text(let text) = contentViews.first! {
            self.isSingleLine = !text.contains("\n") && text.count < 50
        } else {
            self.isSingleLine = false
        }
        
        self.isAssistantMessage = associatedMessage.role == "assistant"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if isAssistantMessage {
                assistantMessageView
            } else {
                userMessageView
            }
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
    
    // Assistant message view
    private var assistantMessageView: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(messageContents.enumerated()), id: \.0) { index, content in
                    contentView(for: content)
                }
            }
            Spacer(minLength: 32)
        }
        .padding(messagePadding)
        .frame(maxWidth: .infinity)
        .background(HitCraftColors.systemMessageBackground)
        .overlay(assistantMessageBorder)
        .clipShape(RoundedRectangle(cornerRadius: bubbleRadius))
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
    
    // Assistant message border
    private var assistantMessageBorder: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 5, height: 2)
                    .offset(x: 0)
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                Rectangle()
                    .fill(HitCraftColors.accent)
                    .frame(width: 5, height: 2)
                    .offset(x: 0)
            }
            .padding(.vertical, 0)
            Spacer()
        }
    }
    
    // User message view
    private var userMessageView: some View {
        HStack(alignment: isSingleLine ? .center : .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(Color.gray.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(messageContents.enumerated()), id: \.0) { index, content in
                    contentView(for: content)
                }
            }
        }
        .padding(messagePadding)
        .frame(maxWidth: .infinity)
        .background(HitCraftColors.userMessageBackground)
        .clipShape(RoundedRectangle(cornerRadius: bubbleRadius))
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
    
    // Helper to determine what view to show for each content type
    @ViewBuilder
    private func contentView(for content: MessageContentView) -> some View {
        switch content {
        case .text(let text):
            Text(text)
                .font(HitCraftFonts.body())
                .foregroundColor(HitCraftColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, isSingleLine ? 8 : 0)
                
        case .sketchUpload(let id, let process):
            SketchUploadRequestView(
                sketchId: id,
                sketchUploadRequestId: id,
                postProcess: process
            )
            .frame(maxWidth: .infinity)
        case .sketchUploadComplete(let sketchId, let sketchUploadRequestId):
            SketchUploadCompleteView(
                sketchId: sketchId,
                sketchUploadRequestId: sketchUploadRequestId
            )
            .frame(maxWidth: .infinity)
        case .referenceSelection(let referenceId, let candidatesId, let optionNumber):
            ReferenceSelectionView(
                referenceId: referenceId,
                referenceCandidatesId: candidatesId,
                selectedOptionNumber: optionNumber
            )
            .frame(maxWidth: .infinity)
        case .songRendering(let taskId, let sketchId, let butcherId):
            SongRenderingView(
                taskId: taskId,
                sketchId: sketchId,
                butcherId: butcherId
            )
            .frame(maxWidth: .infinity)
        }
    }
}

// Helper enum to represent different content views
enum MessageContentView {
    case text(String)
    case sketchUpload(id: String, process: String?)
    case referenceSelection(referenceId: String, candidatesId: String, optionNumber: Int)
    case songRendering(taskId: String, sketchId: String, butcherId: String)
    case sketchUploadComplete(sketchId: String, sketchUploadRequestId: String)
    
    var isText: Bool {
        if case .text = self {
            return true
        }
        return false
    }
}