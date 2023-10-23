import Foundation

@available(iOS 15, *)
extension ChipCollectionView
{
    @MainActor class ViewModel: ObservableObject
    {
        var config: Configuration
        var engagementManager: EngagementManager
        var conversationId: String?

        // MARK: - Public Methods

        init(config: Configuration, manager: EngagementManager, conversationId: String?)
        {
            self.config = config
            self.engagementManager = manager
            self.conversationId = conversationId
        }

        func sendInput(option: ChipOption)
        {
            guard let engagementId = engagementManager.settings?.engagementId
            else
            {
                return
            }

            let request = AddConversationEventRequest(
                conversationId: conversationId,
                directIntentHit: option.directIntentHit,
                engagementId: engagementId,
                input: option.text,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue
            )

            engagementManager.emit(.addConversationEvent, request)
        }
    }
}
