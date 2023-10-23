import Foundation
import SocketIO

struct TypingRequest: SocketData
{
    var conversationId: String?
    var name: String
    var typing: Bool
    var userId: String

    func socketRepresentation() throws -> SocketData
    {
        return [
            "conversationId": conversationId,
            "name": name,
            "typing": typing,
            "userId": userId
        ] as [String: any Hashable]
    }
}
