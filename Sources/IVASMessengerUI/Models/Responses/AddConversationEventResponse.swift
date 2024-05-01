import Foundation
import GenericJSON

public struct AddConversationEventResponse: Codable
{
    var _id: String?
    var conversationId: String?
    var directIntentHit: String?
    var engagementId: String?
    var input: String
    var metadata: [String: JSON]?
    var options: [Option]?
    var participants: UpdateParticipantsResponse?
    var ping: String?
    var ncPing: String?
    var readBy: [String]?
    var recievedBy: [String]?
    var sentAt: TimeInterval
    var sentBy: Participant
    var error: ErrorIVAS?
}
