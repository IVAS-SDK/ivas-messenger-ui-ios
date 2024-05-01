import Foundation
import GenericJSON

struct ProxyOutboundMessage: Codable
{
    var message: JSON
    var conversationId: String?
}
