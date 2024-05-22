import Foundation
import GenericJSON

public struct ChipOption: Codable
{
    public var displayText: String?
    public var input: String
    public var postBack: JSON?
    public var configuration: ChipOptionConfiguration?
    
}
