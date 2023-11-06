import Foundation
import GenericJSON
import SocketIO

struct AddConversationEventRequest: SocketData
{
    var conversationId: String?
    var directIntentHit: String?
    var engagementId: String
    var input: String
    var launchAction: LaunchAction?
    var metadataName: String?
    var metadataValue: SocketData?
    var pendingData: SocketData?
    var ping = UUID().uuidString

    init(
        conversationId: String? = nil,
        directIntentHit: String? = nil,
        engagementId: String,
        input: String,
        launchAction: LaunchAction? = nil,
        metadataName: String? = nil,
        metadataValue: SocketData? = nil,
        pendingData: JSON? = nil,
        ping: String = UUID().uuidString
    )
    {
        self.conversationId = conversationId
        self.directIntentHit = directIntentHit
        self.engagementId = engagementId
        self.input = input
        self.launchAction = launchAction
        self.metadataName = metadataName
        self.metadataValue = metadataValue
        self.pendingData = pendingData?.customSocketRepresentation()
        self.ping = ping
    }

    func socketRepresentation() throws -> SocketData
    {
        var data: [String: SocketData?] = [
            "conversationId": conversationId,
            "directIntentHit": directIntentHit,
            "engagementId": engagementId,
            "input": input,
            "launchAction": try launchAction?.socketRepresentation(),
            "pendingData": pendingData,
            "ping": ping
        ]

        guard let name = metadataName, let value = metadataValue
        else
        {
            return data
        }

        data[name] = value

        return data
    }
}
