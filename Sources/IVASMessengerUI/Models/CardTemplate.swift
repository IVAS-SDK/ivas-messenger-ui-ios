import Foundation
import GenericJSON

struct CardTemplate: Codable, Equatable
{
    var banner: String?
    var buttons: [CardButton]?
    var cards: [SimpleCard]?
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

struct SimpleCard: Codable, Hashable
{
    var buttons: [CardButton]?
    var rows: [[CardRow]]?
    var title: String?
}

enum CardType: String, Codable
{
    case card = "CARD"
    case cardList = "CARD_LIST"
}
