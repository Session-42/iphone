// File: HitCraft-Black/Core/Network/NetworkLogger.swift

import Foundation

// MARK: - Network Logger
final class NetworkLogger {
    private let isDebugMode = true
    
    func log(request url: String, method: String, body: [String: Any]? = nil) {
        guard isDebugMode else { return }
        print("🚀 \(method) \(url)")
        if let body = body {
            print("📦 Request Body: \(body)")
        }
    }
    
    func log(response: URLResponse?, data: Data?) {
        guard isDebugMode,
              let httpResponse = response as? HTTPURLResponse else { return }
        print("📡 Response Status: \(httpResponse.statusCode)")
        if let data = data,
           let responseString = String(data: data, encoding: .utf8) {
            let preview = responseString.count > 500 ? String(responseString.prefix(500)) + "..." : responseString
            print("📄 Response Data: \(preview)")
        }
    }
    
    func log(error: Error) {
        guard isDebugMode else { return }
        print("❌ Error: \(error.localizedDescription)")
    }
}
