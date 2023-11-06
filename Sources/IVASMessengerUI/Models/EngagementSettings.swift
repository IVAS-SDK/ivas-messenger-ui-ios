import SwiftUI

class EngagementSettings: Codable, Equatable
{
    var actionColor: Color?
    var backgroundColorPrimary: Color?
    var backgroundColorSecondary: Color?
    var cards: [Card]?
    var desktopCloseBtn: Bool?
    var engagementId: String?
    var fontFamily: String?
    var inputCharLimit: Int?
    var inputPlaceholder: String?
    var logo: String?
    var mainSubTitle: String?
    var mainTitle: String?
    var newConversationButton: String?
    var newConversationPlaceholder: NewConversationPlaceholder?
    var newConversationSubtitle: String?
    var newConversationTitle: String?
    var poweredBy: Bool?
    var soundNotifications: Bool?
    var tabNotifications: Bool?

    static func == (lhs: EngagementSettings, rhs: EngagementSettings) -> Bool 
    {
        return lhs.engagementId == rhs.engagementId
    }
}
