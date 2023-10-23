import Foundation
import SocketIO

struct GetPaginatedConversationsRequest: SocketData
{
    var maxNumberResults: Int
    var page: Int

    func socketRepresentation() throws -> SocketData
    {
        return [
            "maxNumberResults": maxNumberResults,
            "page": page
        ]
    }
}
