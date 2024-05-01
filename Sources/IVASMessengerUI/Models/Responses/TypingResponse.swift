import Foundation

struct TypingResponse: Codable
{
    var workspaceId: String?
    var typing: Bool
    var userId: String
    var conversationId: String
}
