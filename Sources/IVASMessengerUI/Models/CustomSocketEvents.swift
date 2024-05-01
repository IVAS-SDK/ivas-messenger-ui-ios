import Foundation


enum CustomSocketEvents: String
{
    case engagementGet = "Engagement:get"
    case conversationList = "Conversation:list"
    case conversationUpdateParticipants = "Conversation:updateParticipants"
    case conversationJoin = "Conversation:join"
    case eventList = "Event:list"
    case eventCreate = "Event:create"
    case isTyping = "isTyping"
    case userToken = "UserToken"
}
