import SwiftUI

class MessengerEngagementSettings: Codable, Equatable
{
    var logo: String
    var mainTitle: String
    var mainSubTitle: String
    var newConversationTitle: String
    var newConversationSubtitle: String
    var newConversationButton: String
    var backgroundColorPrimary: Color?
    var backgroundColorSecondary: Color?
    var actionColor: Color?
    //var launcher: Launcher
    var newConversationPlaceholder: NewConversationPlaceholder?
    var poweredBy: Bool
    //var cards: Cards
    var newConversationHeaderTitle: String
    var chatParticipantsTitle: String
    var inputPlaceholder: String
    var desktopCloseBtn: Bool
    var soundNotifications: Bool
    var tabNotifications: Bool
    var fontFamily: String
    var inputCharLimit: Int
    var chatOnlyMode: Bool?
    //var authentication: Authentication?

    static func == (lhs: MessengerEngagementSettings, rhs: MessengerEngagementSettings) -> Bool
    {
        return lhs.mainTitle == rhs.mainTitle
    }
}
