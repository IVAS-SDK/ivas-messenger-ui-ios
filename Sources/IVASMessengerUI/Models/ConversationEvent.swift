import Foundation
import GenericJSON

struct ConversationEvent: Identifiable, Equatable
{
    var conversationId: String?
    var id: String
    var input: String?
    var metadata: [String: JSON]?
    var options: [ChipOption]?
    var sentAt: TimeInterval?
    var sentBy: Participant?
    var typing: Bool?
    var userId: String?

    static func == (lhs: ConversationEvent, rhs: ConversationEvent) -> Bool
    {
        return lhs.id == rhs.id
    }
}
