import SwiftUI

@available(iOS 15, *)
extension LandingView
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

        func onFirstAppear(controller: UIViewController?)
        {
            engagementManager.currentScreen = .landing

            performLaunchAction(controller: controller)
        }

        func onDisappear()
        {
            if pushToConversation
            {
                engagementManager.currentScreen = .conversation
            }
            else if engagementManager.currentScreen == .landing
            {
                engagementManager.currentScreen = .baseApp
            }
        }

        // MARK: - Helper Methods

        private func performLaunchAction(controller: UIViewController?)
        {
            guard let controller = controller, shouldPerformLaunchAction()
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

        private func shouldPerformLaunchAction() -> Bool
        {
            if let input = config.launchAction?.preformedInput, !input.isEmpty
            {
                return true
            }

            return config.launchAction?.preformedIntent != nil
        }
    }
}
