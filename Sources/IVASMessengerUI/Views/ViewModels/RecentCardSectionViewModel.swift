import SwiftUI

@available(iOS 15, *)
extension RecentCardSection
{
    @MainActor class ViewModel: ObservableObject
    {
        @Published var recentConversation: ConversationPreview?

        var config: Configuration
        var engagementManager: EngagementManager
        var eventHandlers = [UUID]()
        var pushToConversationList = false

        // MARK: - Public Methods

        init(config: Configuration, manager: EngagementManager)
        {
            self.config = config
            self.engagementManager = manager

            registerEventHandlers()
        }

        func onAppear()
        {
            registerEventHandlers()
            pushToConversationList = false
        }

        func onFirstAppear()
        {
            registerEventHandlers()
            refreshLastConversation()
        }

        func onDisappear()
        {
            unregisterEventHandlers()

            guard pushToConversationList
            else
            {
                return
            }

            engagementManager.currentScreen = .conversationList
        }

        func onAuthChange(_ isAuthenticated: Bool?)
        {
            refreshLastConversation()
        }

        func onScreenChange(_ screen: Screen)
        {
            guard screen == .landing
            else
            {
                return
            }

            refreshLastConversation()
        }

        func showConversationList(controller: UIViewController?)
        {
            guard let controller = controller
            else
            {
                return
            }

            let view = ConversationListView(config: config, engagementManager: engagementManager)

            pushToConversationList = true
            controller.navigationController?.pushViewController(view.viewController, animated: true)
        }

        // MARK: - Helper Methods

        private func registerEventHandlers()
        {
            guard eventHandlers.isEmpty
            else
            {
                return
            }

            eventHandlers.append(engagementManager.registerHandler(.conversationList)
            { [weak self] (response: ConversationsResponse) in

                guard let convo = response.docs.first
                else
                {
                    return
                }

                self?.recentConversation = ConversationPreview(
                    id: convo.id,
                    input: convo.lastMessage.input,
                    sentAt: convo.lastMessage.sentAt,
                    sentByAvatar: convo.participantsData[convo.lastMessage.sentBy.userId!]?.avatar,
                    sentByName: convo.participantsData[convo.lastMessage.sentBy.userId!]?.name,
                    sentByUserId: convo.lastMessage.sentBy.userId
                )
            })
        }

        private func unregisterEventHandlers()
        {
            eventHandlers.forEach { engagementManager.unregisterHandler(id: $0) }
            eventHandlers = []
        }

        private func refreshLastConversation()
        {
            guard engagementManager.isAuthenticated == true
            else
            {
                return
            }

            let request = GetPaginatedConversationsRequest(max: 1, page: 1)

            engagementManager.emit(.conversationList, request)
        }
    }
}
