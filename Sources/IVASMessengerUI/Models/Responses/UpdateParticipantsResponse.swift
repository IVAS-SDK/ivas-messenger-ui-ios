import Foundation

public struct UpdateParticipantsResponse: Codable
{
    public var conversationId: String
    public var participants: [String]
    public var participantsData: [String: Participant]
}
