import Foundation
import UIKit
import GenericJSON
import SocketIO

@available(iOS 15, *)
extension SurveyView
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

        func getCardTemplate(from:String) -> CardTemplate?
        {
            guard let json = event.metadata?["outputs"]?[from]
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
                let msg = "Unable to read card template: \(error)"
                print(msg)
                
                return nil
            }
        }

        func sendInput(for button: CardButton)
        {
            if (button.directIntentHit != nil) {
                var request = AddConversationEventRequest(
                    conversationId: event.conversationId,
                    userId: engagementManager.userId,
                    directIntentHit: button.directIntentHit,
                    input: button.input ?? "Form submitted",
                    launchAction: config.launchAction,
                    metadataName: config.metadata?.metadataName,
                    metadataValue: config.metadata?.metadataValue,
                    postBack: button.pendingData,
                    prod: engagementManager.configOptions.prod
                )
                engagementManager.configOptions.routineHandler?.beforeAddConversationEvent(payload: &request)
                engagementManager.emit(.eventCreate, request)
                
            }
        }
    }
}
