import Foundation
import GenericJSON

struct LiveChatMessage: Codable
{
    var type: String
    var clazz: String
    var code: Int
    var body: JSON
    
    enum CodingKeys: String, CodingKey {
        case type
        case clazz = "class"
        case code
        case body
    }
}
