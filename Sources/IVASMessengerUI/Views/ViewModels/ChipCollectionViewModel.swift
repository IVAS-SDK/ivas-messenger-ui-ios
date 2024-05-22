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
            var request = AddConversationEventRequest(
                conversationId: conversationId,
                userId: engagementManager.userId,
                directIntentHit: option.configuration?.directIntentHit,
                input: option.input,
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue,
                postBack: option.postBack,
                prod: engagementManager.configOptions.prod
            )

            engagementManager.configOptions.routineHandler?.beforeAddConversationEvent(payload: &request)
            engagementManager.emit(.eventCreate, request)
        }
    }
}
