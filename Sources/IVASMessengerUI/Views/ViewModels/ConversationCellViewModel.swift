import SwiftUI

@available(iOS 15, *)
extension ConversationCell
{
    @MainActor class ViewModel: ObservableObject
    {
        var config: Configuration
        var engagementManager: EngagementManager
        var pushToConversation = false

        // MARK: - Public Methods

        init(config: Configuration, manager: EngagementManager)
        {
            self.config = config
            self.engagementManager = manager
        }

        func onAppear()
        {
            pushToConversation = false
        }

        func onDisappear()
        {
            guard pushToConversation
            else
            {
                return
            }

            engagementManager.currentScreen = .conversation
        }

        func joinConversation(controller: UIViewController?, id: String)
        {
            guard let controller = controller
            else
            {
                return
            }

            let view = ConversationView(
                config: config,
                engagementManager: engagementManager,
                previousScreen: engagementManager.currentScreen,
                conversationId: id
            )

            pushToConversation = true
            controller.navigationController?.pushViewController(view.viewController, animated: true)
        }

        func getName(_ conversation: ConversationPreview) -> String
        {
            return conversation.sentByUserId == engagementManager.userId ?
                String(localized: "ivas.conversationList.userName", bundle: engagementManager.localizationBundle) :
                conversation.sentByName ?? ""
        }

        func getTimeAgo(_ sentAtInMiliseconds: TimeInterval) -> String
        {
            let now = Date()
            let date = Date(timeIntervalSince1970: milisecondsToSeconds(miliseconds: sentAtInMiliseconds))

            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full

            return formatter.localizedString(for: date, relativeTo: now)
        }

        // MARK: - Helper Methods

        private func milisecondsToSeconds(miliseconds: Double) -> Double
        {
            return miliseconds / 1000.0
        }
    }
}
