import SwiftUI

@available(iOS 15, *)
extension ConversationView
{
    enum LoadState
    {
        case initialLoad, loading, loaded
    }

    @MainActor class ViewModel: ObservableObject
    {
        @Published var conversationHistory = [ConversationEvent]()
        @Published var paginationData = PaginationData()
        @Published var conversationId: String?
        
        var doneAppendingToBottom = false
        var engagementManager: EngagementManager
        var eventHandlers = [UUID]()
        var lastTopId = ""
        var loadState = LoadState.initialLoad
        var previousScreen: Screen
        var scrollOffset = CGPoint()
        var scrollView: ScrollViewProxy?

        // MARK: - Public Methods

        init(manager: EngagementManager, previousScreen: Screen, conversationId: String?)
        {
            self.engagementManager = manager
            self.previousScreen = previousScreen
            self.conversationId = conversationId

            registerEventHandlers()
        }

        func onAppear()
        {
            registerEventHandlers()
        }

        func onDisappear()
        {
            unregisterEventHandlers()
            engagementManager.currentScreen = previousScreen
        }

        func onViewsAppearedChange()
        {
            joinConversation()
        }

        func setScrollView(_ scrollView: ScrollViewProxy)
        {
            self.scrollView = scrollView
        }

        func setScrollOffset(_ offset: CGPoint)
        {
            self.scrollOffset = offset

            self.checkIfShouldLoadPage()
        }

        func shouldPerformLaunchAction(config: Configuration) -> Bool
        {
            guard !engagementManager.isLaunchActionPerformed
            else
            {
                return false
            }

            if let input = config.launchAction?.preformedInput, !input.isEmpty
            {
                return true
            }

            if let intent = config.launchAction?.preformedIntent, intent != .Account && intent != .ContactUs
            {
                return true
            }

            return false
        }

        func performLaunchAction(config: Configuration)
        {
            guard let engagementId = engagementManager.settings?.engagementId, shouldPerformLaunchAction(config: config)
            else
            {
                return
            }

            var input = ""
            var directIntent: String? = nil

            if let text = config.launchAction?.preformedInput, !text.isEmpty
            {
                input = text
            }
            else if let data = config.launchAction?.preformedIntent?.mappedData()
            {
                input = data.utterance
                directIntent = data.directIntentHit
            }

            let request = AddConversationEventRequest(
                directIntentHit: directIntent,
                engagementId: engagementId,
                input: input,
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            { [weak self] in

                self?.engagementManager.isLaunchActionPerformed = true
                self?.engagementManager.emit(.addConversationEvent, request)
            }
        }

        func scroll()
        {
            switch loadState
            {
                case .initialLoad:
                    let id = conversationHistory.last?.id ?? ""
                    scrollView?.scrollTo(id, anchor: .bottom)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                    { [weak self] in

                        self?.checkIfShouldLoadPage()
                    }

                case .loading, .loaded:
                    let id = self.doneAppendingToBottom ? conversationHistory.last?.id ?? "" : lastTopId
                    let anchor = self.doneAppendingToBottom ? UnitPoint.bottom : UnitPoint.top
                    loadState = .loaded
                    doneAppendingToBottom = false
                    scrollView?.scrollTo(id, anchor: anchor)
            }
        }

        // MARK: - Helper Methods

        private func registerEventHandlers()
        {
            guard eventHandlers.isEmpty
            else
            {
                return
            }
            
            eventHandlers.append(engagementManager.registerHandler(.doneAddingConversationEvent)
            { [weak self] (response: AddConversationEventResponse) in

                guard let self = self
                else
                {
                    return
                }

                self.doneAppendingToBottom = true
                self.paginationData.skipCounter += 1
                self.conversationId = response.conversationId
                self.conversationHistory.append(self.buildConversationEvent(from: response))
            })

            eventHandlers.append(engagementManager.registerHandler(.doneGettingPaginatedConversationEvents)
            { [weak self] (response: GetPaginatedConversationEventsResponse) in

                guard let self = self
                else
                {
                    return
                }

                self.paginationData.currentPage = response.page
                self.paginationData.pagesRemaining = response.page != response.totalPages
                self.conversationHistory.insert(
                    contentsOf: response.rows.reversed().map({ self.buildConversationEvent(from: $0) }),
                    at: 0
                )
            })

            eventHandlers.append(engagementManager.registerHandler(.isTyping)
            { [weak self] (response: TypingResponse) in

                if response.typing
                {
                    let isTyping = self?.conversationHistory.contains(where:
                    {
                        return $0.typing == true && $0.userId == response.userId
                    })

                    if isTyping == true { return }

                    self?.doneAppendingToBottom = true
                    self?.conversationHistory.append(ConversationEvent(
                        id: UUID().uuidString,
                        sentBy: self?.conversationHistory.first(where: { $0.sentBy?.userId == response.userId })?.sentBy, 
                        typing: response.typing,
                        userId: response.userId
                    ))
                }
                else
                {
                    self?.conversationHistory.removeAll(where:
                    {
                        return $0.typing == true && $0.userId == response.userId
                    })
                }
            })
        }

        private func unregisterEventHandlers()
        {
            eventHandlers.forEach { engagementManager.unregisterHandler(id: $0) }
            eventHandlers = []
        }

        private func joinConversation()
        {
            guard let id = conversationId
            else
            {
                return
            }

            let joinRequest = JoinConversationRequest(conversationId: id)
            let eventsRequest = GetPaginatedConversationEvents(
                _id: id,
                maxNumberResults: paginationData.maxPageSize,
                page: 1,
                skipCounter: paginationData.skipCounter
            )

            engagementManager.emit(.joinConversation, joinRequest)
            engagementManager.emit(.getPaginatedConversationEvents, eventsRequest)
        }

        private func checkIfShouldLoadPage()
        {
            switch loadState
            {
                case .initialLoad:
                    if scrollOffset.y <= 0 && paginationData.pagesRemaining
                    {
                        loadNextPage()
                    }
                    else
                    {
                        loadState = .loaded
                    }

                case .loaded:
                    if scrollOffset.y <= 0 && paginationData.pagesRemaining
                    {
                        loadNextPage()
                    }

                case.loading:
                    return
            }
        }

        private func loadNextPage()
        {
            guard let conversationId = conversationId, let topId = conversationHistory.first?.id
            else
            {
                return
            }

            if loadState == .loaded { loadState = .loading }

            lastTopId = topId

            let request = GetPaginatedConversationEvents(
                _id: conversationId,
                maxNumberResults: paginationData.maxPageSize,
                page: paginationData.currentPage + 1,
                skipCounter: paginationData.skipCounter
            )

            engagementManager.emit(.getPaginatedConversationEvents, request)
        }

        private func buildConversationEvent(from response: AddConversationEventResponse) -> ConversationEvent
        {
            return ConversationEvent(
                conversationId: response.conversationId,
                id: response._id,
                input: response.input,
                metadata: response.metadata,
                options: response.options?.map({
                    ChipOption(displayText: $0.displayText, directIntentHit: $0.directIntentHit, text: $0.text)
                }),
                sentAt: response.sentAt,
                sentBy: response.sentBy
            )
        }
    }
}
