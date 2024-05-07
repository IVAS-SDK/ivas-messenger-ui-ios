import Foundation

public struct Conversation: Codable, Identifiable, Equatable
{
    public var id: String { _id }

    public var _id: String
    public var workspaceId: String
    public var lastMessage: AddConversationEventResponse
    var participants: [String]
    var participantsData: [String: Participant]

    
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool
    {
        return lhs._id == rhs._id
    }
}
