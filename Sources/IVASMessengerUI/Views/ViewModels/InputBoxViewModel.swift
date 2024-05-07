import Foundation

@available(iOS 15, *)
extension InputBox
{
    @MainActor class ViewModel: ObservableObject
    {
        @Published var inputText = ""

        var config: Configuration
        var engagementManager: EngagementManager

        // MARK: - Public Methods

        init(config: Configuration, manager: EngagementManager)
        {
            self.config = config
            self.engagementManager = manager
        }

        func sendInput(conversationId: String?)
        {
            if(inputText == "") {
                return
            }
            
            var request = AddConversationEventRequest(
                conversationId: conversationId,
                userId: engagementManager.userId,
                input: inputText,
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue,
                prod: engagementManager.configOptions.prod
            )

            inputText = ""
            
            // TODO: move emit(.eventCreate to a function in engagementManager, and have handler cover all input sources
            engagementManager.configOptions.routineHandler?.beforeAddConversationEvent(payload: &request)

            engagementManager.emit(.eventCreate, request)
        }

        func getInputPlaceholder() -> String
        {
            guard let placeholder = engagementManager.settings?.inputPlaceholder, !placeholder.isEmpty
            else
            {
                return String(
                    localized: "ivas.inputBox.placeholder",
                    bundle: engagementManager.localizationBundle
                )
            }

            return placeholder
        }
    }
}
