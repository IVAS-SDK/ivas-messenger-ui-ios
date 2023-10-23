import Foundation
import SocketIO

struct JoinConversationRequest: SocketData
{
    var conversationId: String

    func socketRepresentation() throws -> SocketData
    {
        return ["conversationId": conversationId]
    }
}
