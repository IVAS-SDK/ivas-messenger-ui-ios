import Foundation

public struct ChipOption: Identifiable
{
    public let id = UUID().uuidString

    public var displayText: String?
    public var directIntentHit: String?
    public var text: String
}
