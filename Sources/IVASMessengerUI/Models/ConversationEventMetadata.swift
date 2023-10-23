import Foundation
import SocketIO

public class ConversationEventMetadata
{
    public var metadataName: String
    public var metadataValue: [String: SocketData]

    public init(metadataName: String, metadataValue: [String: SocketData])
    {
        self.metadataName = metadataName
        self.metadataValue = metadataValue
    }
}
