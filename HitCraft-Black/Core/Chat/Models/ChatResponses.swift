import Foundation

// MARK: - Message Content Types
enum MessageContentType: String, Codable {
    case text
    case sketch_upload_request
    case reference_selection
    case song_rendering_complete
    case sketch_upload_start
    case sketch_upload_complete
    case unknown
    
    static func from(typeString: String) -> MessageContentType {
        return MessageContentType(rawValue: typeString) ?? .unknown
    }
}

// MARK: - Message Content
enum MessageContent: Codable {
    case text(content: String)
    case sketch_upload_request(sketchUploadRequestId: String, postProcess: String?)
    case reference_selection(referenceId: String, referenceCandidatesId: String, optionNumber: Int)
    case song_rendering_complete(taskId: String, sketchId: String, butcherId: String)
    case sketch_upload_start(taskId: String, fileName: String, sketchUploadRequestId: String)
    case sketch_upload_complete(taskId: String, sketchId: String, sketchUploadRequestId: String, songName: String)
    case unknown(type: String)
    
    // Custom coding keys
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case sketchUploadRequestId
        case postProcess
        case referenceId
        case referenceCandidatesId
        case optionNumber
        case taskId
        case sketchId
        case butcherId
        case fileName
        case songName
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
            
        case MessageContentType.reference_selection.rawValue:
            let referenceId = try container.decode(String.self, forKey: .referenceId)
            let referenceCandidatesId = try container.decode(String.self, forKey: .referenceCandidatesId)
            let optionNumber = try container.decode(Int.self, forKey: .optionNumber)
            self = .reference_selection(referenceId: referenceId, referenceCandidatesId: referenceCandidatesId, optionNumber: optionNumber)

        case MessageContentType.song_rendering_complete.rawValue:
            let taskId = try container.decode(String.self, forKey: .taskId)
            let sketchId = try container.decode(String.self, forKey: .sketchId)
            let butcherId = try container.decode(String.self, forKey: .butcherId)
            self = .song_rendering_complete(taskId: taskId, sketchId: sketchId, butcherId: butcherId)
            
        case MessageContentType.sketch_upload_start.rawValue:
            let taskId = try container.decode(String.self, forKey: .taskId)
            let fileName = try container.decode(String.self, forKey: .fileName)
            let sketchUploadRequestId = try container.decode(String.self, forKey: .sketchUploadRequestId)
            self = .sketch_upload_start(taskId: taskId, fileName: fileName, sketchUploadRequestId: sketchUploadRequestId)
            
        case MessageContentType.sketch_upload_complete.rawValue:
            let taskId = try container.decode(String.self, forKey: .taskId)
            let sketchId = try container.decode(String.self, forKey: .sketchId)
            let sketchUploadRequestId = try container.decode(String.self, forKey: .sketchUploadRequestId)
            let songName = try container.decode(String.self, forKey: .songName)
            self = .sketch_upload_complete(taskId: taskId, sketchId: sketchId, sketchUploadRequestId: sketchUploadRequestId, songName: songName)
            
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
        case .reference_selection(let referenceId, let referenceCandidatesId, let optionNumber):
            try container.encode(MessageContentType.reference_selection.rawValue, forKey: .type)
            try container.encode(referenceId, forKey: .referenceId)
            try container.encode(referenceCandidatesId, forKey: .referenceCandidatesId)
            try container.encode(optionNumber, forKey: .optionNumber)
        case .song_rendering_complete(let taskId, let sketchId, let butcherId):
            try container.encode(MessageContentType.song_rendering_complete.rawValue, forKey: .type)
            try container.encode(taskId, forKey: .taskId)
            try container.encode(sketchId, forKey: .sketchId)
            try container.encode(butcherId, forKey: .butcherId)
            
        case .sketch_upload_start(let taskId, let fileName, let sketchUploadRequestId):
            try container.encode(MessageContentType.sketch_upload_start.rawValue, forKey: .type)
            try container.encode(taskId, forKey: .taskId)
            try container.encode(fileName, forKey: .fileName)
            try container.encode(sketchUploadRequestId, forKey: .sketchUploadRequestId)
            
        case .sketch_upload_complete(let taskId, let sketchId, let sketchUploadRequestId, let songName):
            try container.encode(MessageContentType.sketch_upload_complete.rawValue, forKey: .type)
            try container.encode(taskId, forKey: .taskId)
            try container.encode(sketchId, forKey: .sketchId)
            try container.encode(sketchUploadRequestId, forKey: .sketchUploadRequestId)
            try container.encode(songName, forKey: .songName)
            
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
         case .reference_selection(let referenceId, let referenceCandidatesId, let optionNumber):
            return [
                "type": MessageContentType.reference_selection.rawValue,
                "referenceId": referenceId,
                "referenceCandidatesId": referenceCandidatesId,
                "optionNumber": optionNumber
            ]
        case .song_rendering_complete(let taskId, let sketchId, let butcherId):
            return [
                "type": MessageContentType.song_rendering_complete.rawValue,
                "taskId": taskId,
                "sketchId": sketchId,
                "butcherId": butcherId
            ]
        case .sketch_upload_start(let taskId, let fileName, let sketchUploadRequestId):
            return [
                "type": MessageContentType.sketch_upload_start.rawValue,
                "taskId": taskId,
                "fileName": fileName,
                "sketchUploadRequestId": sketchUploadRequestId
            ]
        case .sketch_upload_complete(let taskId, let sketchId, let sketchUploadRequestId, let songName):
            return [
                "type": MessageContentType.sketch_upload_complete.rawValue,
                "taskId": taskId,
                "sketchId": sketchId,
                "sketchUploadRequestId": sketchUploadRequestId,
                "songName": songName
            ]
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

    static func referenceSelection(referenceId: String, referenceCandidatesId: String, optionNumber: Int) -> MessageContent {
        return .reference_selection(referenceId: referenceId, referenceCandidatesId: referenceCandidatesId, optionNumber: optionNumber)
    }

    static func songRenderingComplete(taskId: String, sketchId: String, butcherId: String) -> MessageContent {
        return .song_rendering_complete(taskId: taskId, sketchId: sketchId, butcherId: butcherId)
    }
    
    static func sketchUploadStart(taskId: String, fileName: String, sketchUploadRequestId: String) -> MessageContent {
        return .sketch_upload_start(taskId: taskId, fileName: fileName, sketchUploadRequestId: sketchUploadRequestId)
    }
    
    static func sketchUploadComplete(taskId: String, sketchId: String, sketchUploadRequestId: String, songName: String) -> MessageContent {
        return .sketch_upload_complete(taskId: taskId, sketchId: sketchId, sketchUploadRequestId: sketchUploadRequestId, songName: songName)
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