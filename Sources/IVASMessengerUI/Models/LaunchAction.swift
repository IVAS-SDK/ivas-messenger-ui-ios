import Foundation
import SocketIO

public struct LaunchAction
{
    public var name: String?
    public var utterance: String?
    public var directIntentHit: String?
    
    public init(name: String? = nil, utterance: String? = nil, directIntentHit: String? = nil)
    {
        self.name = name
        self.utterance = utterance
        self.directIntentHit = directIntentHit
    }
}
