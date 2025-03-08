import SwiftUI
import WebKit

struct MessageBubble: View {
    let isFromUser: Bool
    let text: String
    let associatedMessage: ChatMessage?
    
    init(isFromUser: Bool, text: String, associatedMessage: ChatMessage? = nil) {
        self.isFromUser = isFromUser
        self.text = text
        self.associatedMessage = associatedMessage
    }
    
    // Parse message content to separate text, YouTube embeds, and other content types
    private var parsedContent: [(type: String, content: String)] {
        var result: [(type: String, content: String)] = []
        var remainingText = text
        
        // Find all iframe tags in the text
        while let iframeStartRange = remainingText.range(of: "<iframe", options: .caseInsensitive) {
            // Add text before iframe as regular text
            let textBeforeIframe = remainingText[..<iframeStartRange.lowerBound]
            if !textBeforeIframe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                result.append((type: "text", content: String(textBeforeIframe)))
            }
            
            // Find the end of the iframe tag
            if let iframeEndRange = remainingText.range(of: "</iframe>", options: .caseInsensitive, range: iframeStartRange.upperBound..<remainingText.endIndex) {
                let iframeTag = remainingText[iframeStartRange.lowerBound...iframeEndRange.upperBound]
                
                // Extract the YouTube video ID
                if let srcRange = iframeTag.range(of: "src=\"https://www.youtube.com/embed/", options: .caseInsensitive),
                   let endRange = iframeTag[srcRange.upperBound...].range(of: "\"", options: .caseInsensitive) {
                    let videoIDRange = srcRange.upperBound..<endRange.lowerBound
                    let videoID = String(iframeTag[videoIDRange])
                    result.append((type: "youtube", content: videoID))
                }
                
                // Update remaining text
                remainingText = String(remainingText[iframeEndRange.upperBound...])
            } else {
                // If no closing iframe tag, just add the rest as text
                result.append((type: "text", content: remainingText))
                break
            }
        }
        
        // Add any remaining text
        if !remainingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result.append((type: "text", content: remainingText))
        }
        
        return result
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                if isFromUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Display parsed content
                    ForEach(Array(parsedContent.enumerated()), id: \.offset) { index, item in
                        if item.type == "text" {
                            // Simply clean the markdown symbols without trying to render them
                            Text(MarkdownCleaner.cleanMarkdown(item.content))
                                .font(HitCraftFonts.body())
                                .foregroundColor(HitCraftColors.text)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if item.type == "youtube" {
                            YouTubeVideoView(videoID: item.content)
                                .frame(height: 220)
                                .cornerRadius(12)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isFromUser {
                    Spacer(minLength: 32)
                }
            }
            .padding(HitCraftLayout.messagePadding)
            .frame(maxWidth: .infinity)
            .background(isFromUser ? HitCraftColors.userMessageBackground : HitCraftColors.systemMessageBackground)
            .overlay(
                Group {
                    if !isFromUser {
                        HStack(spacing: 0) {
                            // Left pink border
                            VStack(spacing: 0) {
                                // Top extension
                                Rectangle()
                                    .fill(HitCraftColors.accent)
                                    .frame(width: 5, height: 2)
                                    .offset(x: 0)
                                
                                // Vertical line
                                Rectangle()
                                    .fill(HitCraftColors.accent)
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                                
                                // Bottom extension
                                Rectangle()
                                    .fill(HitCraftColors.accent)
                                    .frame(width: 5, height: 2)
                                    .offset(x: 0)
                            }
                            .padding(.vertical, 0)
                            
                            Spacer()
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HitCraftLayout.messageBubbleRadius))
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

// Custom WebView for YouTube videos
struct YouTubeVideoView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Set content mode to mobile to make sure it works properly
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        webView.configuration.defaultWebpagePreferences = preferences
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Build a custom HTML page for embedding YouTube
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; background-color: transparent; }
            .video-container { position: relative; width: 100%; height: 100%; }
            iframe { width: 100%; height: 100%; border: none; border-radius: 12px; }
          </style>
        </head>
        <body>
          <div class="video-container">
            <iframe src="https://www.youtube.com/embed/\(videoID)?playsinline=1&rel=0&modestbranding=1" 
                    frameborder="0" allowfullscreen allow="autoplay; encrypted-media">
            </iframe>
          </div>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: nil)
    }
}
