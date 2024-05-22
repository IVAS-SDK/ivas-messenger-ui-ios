import Foundation
import GenericJSON

struct CardTemplate: Codable, Equatable
{
    var image: String?
    var title: String?
    var rows: [CardRow]?
    var buttons: [CardButton]?
    
    
    var type: CardType
    var cards: [SimpleCard]?
}

struct CardButton: Codable, Hashable
{
    var directIntentHit: String?
    var input: String?
    var pendingData: JSON?

    // valid for type ToggleVisibility
    var targetElements: [String]?
    var isVisible: Bool?

    // valid for type DisplayText
    var text: String?
    
    //valid for type OpenUrl
    var url: String?

    // valid for all
    var type: String?

    var title: String
}

struct CardRow: Codable, Hashable
{
    var title: String
    var value: String
}

struct SimpleCard: Codable, Hashable
{
    var id: String?
    var title: String?
    var image: String?
    var buttons: [CardButton]?
    var rows: [CardRow]?
    var isVisible: Bool?
}

enum CardType: String, Codable
{
    case card = "CARD"
    case cardList = "CARD_LIST"
}
