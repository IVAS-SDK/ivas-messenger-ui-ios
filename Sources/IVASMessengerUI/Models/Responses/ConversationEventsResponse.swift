import Foundation

struct ConversationEventsResponse: Codable
{
    var conversation: Conversation
    var page: Int
    var docs: [AddConversationEventResponse]
    var total: Int
    var error: ErrorIVAS?
}

