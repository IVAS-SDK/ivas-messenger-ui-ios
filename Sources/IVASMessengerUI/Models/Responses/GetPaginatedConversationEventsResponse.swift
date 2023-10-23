import Foundation

struct GetPaginatedConversationEventsResponse: Codable
{
    var conversation: Conversation
    var page: Int
    var rows: [AddConversationEventResponse]
    var total: Int
    var totalPages: Int
}
