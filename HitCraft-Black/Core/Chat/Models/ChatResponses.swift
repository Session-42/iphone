import Foundation

// MARK: - Message Content Types
enum MessageContentType: String, Codable {
    case text
    case sketch_upload_request
    case unknown
    
    static func from(typeString: String) -> MessageContentType {
        return MessageContentType(rawValue: typeString) ?? .unknown
    }
}

// MARK: - Message Content
enum MessageContent: Codable {
    case text(content: String)
    case sketch_upload_request(sketchUploadRequestId: String, postProcess: String?)
    case unknown(type: String)
    
    // Custom coding keys
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case sketchUploadRequestId
        case postProcess
    }
    
    // Implement init(from:) to decode based on the "type" field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        
        switch typeString {
        case MessageContentType.text.rawValue:
            if let text = try container.decodeIfPresent(String.self, forKey: .text) {
                self = .text(content: text)
            } else {
                self = .text(content: "")
            }
            
        case MessageContentType.sketch_upload_request.rawValue:
            let sketchId = try container.decode(String.self, forKey: .sketchUploadRequestId)
            let postProcess = try container.decodeIfPresent(String.self, forKey: .postProcess)
            self = .sketch_upload_request(sketchUploadRequestId: sketchId, postProcess: postProcess)
            
        default:
            self = .unknown(type: typeString)
        }
    }
    
    // Implement encode(to:) to encode the appropriate fields based on the case
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let content):
            try container.encode(MessageContentType.text.rawValue, forKey: .type)
            try container.encode(content, forKey: .text)
            
        case .sketch_upload_request(let sketchId, let postProcess):
            try container.encode(MessageContentType.sketch_upload_request.rawValue, forKey: .type)
            try container.encode(sketchId, forKey: .sketchUploadRequestId)
            if let postProcess = postProcess {
                try container.encode(postProcess, forKey: .postProcess)
            }
            
        case .unknown(let type):
            try container.encode(type, forKey: .type)
        }
    }
}

// MARK: - Message sender helpers
extension MessageContent {
    // Create a dictionary representation for sending in a request
    func toDictionary() -> [String: Any] {
        switch self {
        case .text(let content):
            return ["type": MessageContentType.text.rawValue, "text": content]
        case .sketch_upload_request(let sketchId, let postProcess):
            var dict: [String: Any] = [
                "type": MessageContentType.sketch_upload_request.rawValue,
                "sketchUploadRequestId": sketchId
            ]
            if let postProcess = postProcess {
                dict["postProcess"] = postProcess
            }
            return dict
        case .unknown(let type):
            return ["type": type]
        }
    }
    
    // Create a text message content
    static func text(_ text: String) -> MessageContent {
        return .text(content: text)
    }

    static func sketchUploadRequest(id: String, postProcess: String? = "analyze_sketch") -> MessageContent {
        return .sketch_upload_request(sketchUploadRequestId: id, postProcess: postProcess)
    }
}

struct MessageData: Codable {
    let content: [MessageContent]
    let timestamp: String
    let role: String
    let id: String
}

struct MessageResponse: Codable {
    let message: MessageData
    let messageId: String
}

struct MessagesResponse: Codable {
    let messages: [MessageData]
}

struct ThreadData: Codable {
    let title: String
    let artistId: String
    let lastMessageAt: String?
}

struct ThreadsResponse: Codable {
    let threads: [String: ThreadData]
}

struct CreateChatResponse: Codable {
    let threadId: String
}