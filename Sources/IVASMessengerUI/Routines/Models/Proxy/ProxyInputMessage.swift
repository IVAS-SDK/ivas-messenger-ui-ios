import Foundation
import GenericJSON

struct ProxyInputMessage: Codable
{
    var input: String
    var conversationId: String?
    var metadata: [String: JSON]
}
