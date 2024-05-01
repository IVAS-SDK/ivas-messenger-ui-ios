import Foundation

public protocol IEngagementRoutine
{
    func afterAddConversationEvent(payload: AddConversationEventResponse) -> Bool

    func beforeAddConversationEvent(payload: inout AddConversationEventRequest)

    func onEngagementLoad(settings: String)

    func onAction()
}
