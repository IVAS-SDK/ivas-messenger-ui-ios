import Foundation
import GenericJSON
import SocketIO

public struct AddConversationEventRequest: SocketData
{
    let CHANNEL = "MobileSDK"
    
    var conversationId: String?
    var userId: String?
    var directIntentHit: String?
    var input: String
    var launchAction: LaunchAction?
    var metadataName: String?
    var metadataValue: SocketData?
    var liveChatState: String?
    var postBack: SocketData?
    var ping = UUID().uuidString
    var ncPing = UUID().uuidString
    var prod: Bool

    init(
        conversationId: String? = nil,
        userId: String?,
        directIntentHit: String? = nil,
        input: String,
        launchAction: LaunchAction? = nil,
        metadataName: String? = nil,
        metadataValue: SocketData? = nil,
        postBack: JSON? = nil,
        ping: String = UUID().uuidString,
        prod: Bool = true
    )
    {
        self.conversationId = conversationId
        self.userId = userId
        self.directIntentHit = directIntentHit
        self.input = input
        self.launchAction = launchAction
        self.metadataName = metadataName
        self.metadataValue = metadataValue
        self.postBack = postBack?.customSocketRepresentation()
        self.ping = ping
        self.prod = prod
    }
    
    
    public func socketRepresentation() throws -> SocketData
    {

        var data: [String: SocketData?] = [
            "input": input,
            "ping": ping
        ]
        if(directIntentHit != nil) {
            data["configuration"] = ["directIntentHit":directIntentHit]
        }
        
        if(launchAction != nil) {
            data["launchAction"] = ["preformedIntent":launchAction?.preformedIntent?.rawValue]
        }
        
        if(postBack != nil) {
            data["postBack"] = postBack
        }
        
            if(conversationId != nil) {
                data["conversationId"] = conversationId
            } else {
                data["ncPing"] = UUID().uuidString
            }
        
            
        if(userId != nil) {
            data["sentBy"] = ["userId":userId]
        }
        
        var metadata: [String: SocketData?] = [:]
        
        // add any metadata from user
        if let name = metadataName, let value = metadataValue {
            metadata[name] = value
        }
        
        metadata["channel"] = CHANNEL
        
        if(liveChatState != nil) {
            metadata["livechatState"] = liveChatState
        }
        
        data["metadata"] = metadata
        
        data["params"] = ["prod":prod]

        return data
    }
}
