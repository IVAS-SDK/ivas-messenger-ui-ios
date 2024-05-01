import Foundation

struct PresenceActionMessage: Codable
{
    var action: String
    var token: String
    var message: PresenceMessage
    var channel: PresenceChannelData
}
