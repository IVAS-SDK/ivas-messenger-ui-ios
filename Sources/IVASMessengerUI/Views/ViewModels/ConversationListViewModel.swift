import Foundation

@available(iOS 15, *)
extension ConversationListView
{
    @MainActor class ViewModel: ObservableObject
    {
        @Published var conversationList = [Conversation]()
        @Published var paginationData = PaginationData(pagesRemaining: true)

        var engagementManager: EngagementManager
        var eventHandlers = [UUID]()

        // MARK: - Public Methods

        init(manager: EngagementManager)
        {
            self.engagementManager = manager

            registerEventHandlers()
        }

        func onAppear()
        {
            registerEventHandlers()
        }

        func onDisappear()
        {
            unregisterEventHandlers()
            conversationList = []

            guard engagementManager.currentScreen == .conversationList
            else
            {
                return
            }

            engagementManager.currentScreen = .landing
        }

        func onScreenChange(_ screen: Screen)
        {
            guard screen == .conversationList
            else
            {
                return
            }

            refreshConversationList()
        }

        func loadNextPage()
        {
            guard paginationData.pagesRemaining
            else
            {
                return
            }

            let request = GetPaginatedConversationsRequest(
                max: paginationData.maxPageSize,
                page: paginationData.currentPage + 1
            )

            engagementManager.emit(.conversationList, request)
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

                self?.paginationData.currentPage = response.page
                
                var totalPages = response.total / (self?.paginationData.maxPageSize ?? 10)
                if(response.total % (self?.paginationData.maxPageSize ?? 10) > 0) {
                    totalPages+=1 }
                
                self?.paginationData.pagesRemaining = response.page != totalPages
                self?.conversationList.append(contentsOf: response.docs)
            })
        }

        private func unregisterEventHandlers()
        {
            eventHandlers.forEach { engagementManager.unregisterHandler(id: $0) }
            eventHandlers = []
        }

        private func refreshConversationList()
        {
            conversationList = [Conversation]()
            paginationData = PaginationData(pagesRemaining: true)

            loadNextPage()
        }
    }
}
