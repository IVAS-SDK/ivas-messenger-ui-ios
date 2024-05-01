import Foundation

struct PresenceMessage: Codable
{
    var type: String
    var events: [PresenceEvent]
}
