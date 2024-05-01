import Foundation
import SocketIO

struct GetPaginatedConversationEvents: SocketData
{
    var conversationId: String
    var page: Int
    var max: Int
    func socketRepresentation() throws -> SocketData
    {
        return [
            "conversationId": conversationId,
            "max": max,
            "page": page,
        ] as [String: any Hashable]
    }
}
