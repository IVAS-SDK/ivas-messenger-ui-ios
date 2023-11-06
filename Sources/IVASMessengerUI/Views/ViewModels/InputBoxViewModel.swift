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
            guard let engagementId = engagementManager.settings?.engagementId
            else
            {
                return
            }

            let request = AddConversationEventRequest(
                conversationId: conversationId,
                engagementId: engagementId,
                input: inputText,
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue
            )

            inputText = ""

            engagementManager.emit(.addConversationEvent, request)
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
