import Foundation
import GenericJSON
import SocketIO

@available(iOS 15, *)
extension CardView
{
    @MainActor class ViewModel: ObservableObject
    {
        @Published var showMessage: Bool = false
        var message: String = ""
        
        var config: Configuration
        var engagementManager: EngagementManager
        var event: ConversationEvent
        
        //var showingAlert: Bool = false

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
                
                //let str = String(data: data, encoding: .utf8)
                
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
            
            if ((button.type == "ToggleVisibility") && (button.targetElements != nil)) {
                //for (cardId in button.targetElements!!) {
                //    this.cardListView?.toggleCardVisibility(cardId)
                //}
            } else if ((button.type == "DisplayText") && button.text != nil) {
                
                message = button.text ?? ""
                showMessage = true
                print(button.text!)
                
            } else if ((button.directIntentHit != nil) && (button.pendingData != nil)) {
                let request = AddConversationEventRequest(
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
                
                engagementManager.emit(.eventCreate, request)
                
            }
        }
    }
}
