import Foundation
import SocketIO

struct AuthenticateRequest: SocketData
{
    var token: String

    func socketRepresentation() throws -> SocketData
    {
        return ["token": token]
    }
}
