import Foundation

public struct UpdateParticipantsResponse: Codable
{
    public var _id: String
    public var workspaceId: String
    //public var lastMessage: AddConversationEventResponse
    public var participants: [String]
    public var participantsData: [String: Participant]
    
}

