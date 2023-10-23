import Foundation

struct GetPaginatedConversationsResponse: Codable, Equatable
{
    var page: Int
    var rows: [Conversation]
    var total: Int
    var totalPages: Int
}
