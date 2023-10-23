import Foundation

struct NewConversation: Codable
{
    var initialMessage: String?
    var options: [Option]?
}

struct NewConversationCode: Codable
{
    var html: NewConversation?

    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let jsonString = try container.decode(String.self, forKey: .html)

        self.html = try JSONDecoder().decode(NewConversation.self, from: Data(jsonString.utf8))
    }
}

struct NewConversationPlaceholder: Codable
{
    var code: NewConversationCode?
}
