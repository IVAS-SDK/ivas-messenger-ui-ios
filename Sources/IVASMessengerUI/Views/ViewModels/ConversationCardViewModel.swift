import SwiftUI

@available(iOS 15, *)
extension ConversationCard
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

        func startNewConversation(controller: UIViewController?)
        {
            guard let controller = controller
            else
            {
                return
            }

            let view = ConversationView(
                config: config,
                engagementManager: engagementManager,
                previousScreen: .landing
            )

            pushToConversation = true
            controller.navigationController?.pushViewController(view.viewController, animated: true)
        }
    }
}
