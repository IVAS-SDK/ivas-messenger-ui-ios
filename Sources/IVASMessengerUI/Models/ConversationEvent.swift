import Foundation
import GenericJSON

public struct ConversationEvent: Identifiable, Equatable
{
    public var conversationId: String?
    public var id: String
    public var input: String?
    public var metadata: [String: JSON]?
    public var options: [ChipOption]?
    public var sentAt: TimeInterval?
    public var sentBy: Participant?
    public var typing: Bool?
    public var userId: String?

    public static func == (lhs: ConversationEvent, rhs: ConversationEvent) -> Bool
    {
        return lhs.id == rhs.id
    }
}
