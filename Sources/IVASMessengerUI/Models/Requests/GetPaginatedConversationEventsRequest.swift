import Foundation
import SocketIO

struct GetPaginatedConversationEvents: SocketData
{
    var _id: String
    var maxNumberResults: Int
    var page: Int
    var skipCounter: Int

    func socketRepresentation() throws -> SocketData
    {
        return [
            "_id": _id,
            "maxNumberResults": maxNumberResults,
            "page": page,
            "skipCounter": skipCounter
        ] as [String: any Hashable]
    }
}
