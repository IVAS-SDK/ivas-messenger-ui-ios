import Foundation

struct ChipOption: Identifiable
{
    let id = UUID().uuidString

    var displayText: String?
    var directIntentHit: String?
    var text: String
}
