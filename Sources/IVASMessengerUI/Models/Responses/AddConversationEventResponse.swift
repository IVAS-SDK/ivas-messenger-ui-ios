import Foundation
import GenericJSON

public struct AddConversationEventResponse: Codable
{
    public var _id: String
    public var conversationId: String
    public var directIntentHit: String?
    public var engagementId: String?
    public var input: String
    public var metadata: [String: JSON]?
    public var options: [Option]?
    public var participants: UpdateParticipantsResponse?
    public var ping: String?
    public var readBy: [String]?
    public var recievedBy: [String]?
    public var sentAt: TimeInterval
    public var sentBy: Participant
    public var whTranId: String?
}
