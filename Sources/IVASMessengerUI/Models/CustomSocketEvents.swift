import Foundation

enum CustomSocketEvents: String
{
    case addConversationEvent
    case authenticate
    case authenticated
    case doneAddingConversationEvent
    case doneGettingEngagementBasedOnRules
    case doneGettingPaginatedConversationEvents
    case doneGettingPaginatedConversations
    case doneUpdatingParticipants
    case getPaginatedConversationEvents
    case getPaginatedConversations
    case getEngagementBasedOnRules
    case isTyping
    case joinConversation
    case unauthorized
}
