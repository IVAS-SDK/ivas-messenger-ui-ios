import Foundation
import SocketIO

struct GetPaginatedConversationsRequest: SocketData
{
    var max: Int
    var page: Int

    func socketRepresentation() throws -> SocketData
    {
        return [
            "max": max,
            "page": page
        ]
    }
}
