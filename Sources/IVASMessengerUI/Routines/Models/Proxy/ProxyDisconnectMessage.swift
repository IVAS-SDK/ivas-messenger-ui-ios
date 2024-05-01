import Foundation

struct ProxyDisconnectMessage: Codable
{
    var conversationId: String?
    var engagementId: String?
    var guid: String?
}
