import Foundation

struct PresenceEvent: Codable
{
    var eventType: String
    var presence: PresenceType
}
