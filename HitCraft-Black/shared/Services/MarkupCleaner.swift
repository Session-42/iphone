// File: HitCraft-Black/Utils/MarkdownCleaner.swift

import Foundation

struct MarkdownCleaner {
    /// Simple function to remove markdown symbols from text
    static func cleanMarkdown(_ text: String) -> String {
        var cleanedText = text
        
        // Remove heading markers (# headers)
        cleanedText = cleanedText.replacingOccurrences(of: "### ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "## ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "# ", with: "")
        
        // Replace list markers with proper bullets
        cleanedText = cleanedText.replacingOccurrences(of: "- ", with: "• ")
        cleanedText = cleanedText.replacingOccurrences(of: "* ", with: "• ")
        
        // Remove bold markers
        cleanedText = cleanedText.replacingOccurrences(of: "**", with: "")
        
        // Remove italic markers
        cleanedText = cleanedText.replacingOccurrences(of: "*", with: "")
        
        // Remove other common markdown symbols
        cleanedText = cleanedText.replacingOccurrences(of: "~~", with: "")  // Strikethrough
        cleanedText = cleanedText.replacingOccurrences(of: "`", with: "")   // Code
        
        return cleanedText
    }
}
