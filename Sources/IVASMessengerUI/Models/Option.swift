import Foundation

public struct Option: Codable
{
    public var displayText: String?
    public var input: String
    public var configuration: ChipOptionConfiguration?
}
