import Foundation
import GenericJSON

struct CardTemplate: Codable, Equatable
{
    var banner: String?
    var buttons: [CardButton]?
    var image: String?
    var rows: [[CardRow]]?
    var title: String?
    var type: CardType
}

struct CardButton: Codable, Hashable
{
    var directIntentHit: String?
    var input: String
    var pendingData: JSON?
    var title: String
}

struct CardRow: Codable, Hashable
{
    var title: String
    var value: String
}

enum CardType: String, Codable
{
    case card = "CARD"
}
