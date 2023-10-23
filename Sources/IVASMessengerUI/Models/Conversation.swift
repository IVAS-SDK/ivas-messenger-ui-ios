import Foundation

struct Conversation: Codable, Identifiable, Equatable
{
    var id: String { _id }

    var _id: String
    var lastMessage: AddConversationEventResponse
    var participants: [String]
    var participantsData: [String: Participant]
    var startedAt: Int
    var startedBy: String

    static func == (lhs: Conversation, rhs: Conversation) -> Bool
    {
        return lhs._id == rhs._id
    }
}
