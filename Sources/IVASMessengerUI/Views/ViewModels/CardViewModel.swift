import Foundation
import GenericJSON
import SocketIO

@available(iOS 15, *)
extension CardView
{
    @MainActor class ViewModel: ObservableObject
    {
        var config: Configuration
        var engagementManager: EngagementManager
        var event: ConversationEvent

        // MARK: - Public Methods

        init(config: Configuration, manager: EngagementManager, event: ConversationEvent)
        {
            self.config = config
            self.engagementManager = manager
            self.event = event
        }

        func getCardTemplate() -> CardTemplate?
        {
            guard let json = event.metadata?["outputs"]?["templateData"]
            else
            {
                return nil
            }

            do
            {
                let data = try JSONEncoder().encode(json)

                return try JSONDecoder().decode(CardTemplate.self, from: data)
            }
            catch
            {
                print("Unable to read card template: \(error)")

                return nil
            }
        }

        func sendInput(for button: CardButton)
        {
            let request = AddConversationEventRequest(
                conversationId: event.conversationId,
                userId: engagementManager.userId,
                directIntentHit: button.directIntentHit,
                input: button.input,
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue,
                postBack: button.pendingData,
                prod: engagementManager.configOptions.prod
            )

            engagementManager.emit(.eventCreate, request)
        }
    }
}
