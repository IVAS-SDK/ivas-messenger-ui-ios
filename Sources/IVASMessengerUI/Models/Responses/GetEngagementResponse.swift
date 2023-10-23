import Foundation

struct GetEngagementResponse: Codable
{
    var cb: String
    var httpToken: String
    var settings: EngagementSettings
}
