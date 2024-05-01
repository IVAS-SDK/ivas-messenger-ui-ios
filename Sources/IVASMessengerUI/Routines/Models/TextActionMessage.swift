import Foundation

struct TextActionMessage: Codable
{
    var action: String
    var token: String
    var message: TextMessage
}
