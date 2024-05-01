import Foundation

struct GetEngagementResponse: Codable
{
    var _id: String
        var workspaceId: String
        var messengerId: String
        var organizationId: String
        var name: String
        var description: String
        var status: Status
        var webhooks: [WebHook]
        var entryPoints: [EntryPoint]
        var settings: MessengerEngagementSettings
        var routines: MessengerEngagementRoutines
        var error: ErrorIVAS?
}
