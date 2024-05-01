import Foundation

struct ConversationsResponse: Codable
{
    var page: Int
    var docs: [Conversation]
    var total: Int
    var error: ErrorIVAS?
}
