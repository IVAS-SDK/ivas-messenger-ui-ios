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

            if let utterance = config.launchAction?.utterance, !utterance.isEmpty
            {
                return true
            }

            return false
        }

        func performLaunchAction(config: Configuration)
        {
            //guard let engagementId = engagementManager.settings?.engagementId,
            if(!shouldPerformLaunchAction(config: config)) {return }

            let input = (config.launchAction?.utterance)!
            let directIntent = config.launchAction?.directIntentHit

            var request = AddConversationEventRequest(
                userId:engagementManager.userId,
                directIntentHit: directIntent,
                input: input,
                launchAction: config.launchAction,
                metadataName: config.metadata?.metadataName,
                metadataValue: config.metadata?.metadataValue,
                prod: engagementManager.configOptions.prod
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            { [weak self] in

                self?.engagementManager.isLaunchActionPerformed = true
                self?.engagementManager.configOptions.routineHandler?.beforeAddConversationEvent(payload: &request)
                self?.engagementManager.emit(.eventCreate, request)
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
            
            eventHandlers.append(engagementManager.registerHandler(.eventCreate)
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

            eventHandlers.append(engagementManager.registerHandler(.eventList)
            { [weak self] (response: ConversationEventsResponse) in

                guard let self = self
                else
                {
                    return
                }
                
                var totalPages = response.total / paginationData.maxPageSize
                if(response.total % paginationData.maxPageSize > 0) {
                    totalPages+=1 }

                self.paginationData.currentPage = response.page
                self.paginationData.pagesRemaining = response.page != totalPages
                self.conversationHistory.insert(
                    contentsOf: response.docs.reversed().map({ self.buildConversationEvent(from: $0) }),
                    at: 0
                )
            })

            /*eventHandlers.append(engagementManager.registerHandler(.isTyping)
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
            })*/
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
                conversationId: id,
                page: 1,
                max: paginationData.maxPageSize
            )

            engagementManager.emit(.conversationJoin, joinRequest)
            engagementManager.emit(.eventList, eventsRequest)
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
                conversationId:conversationId,
                
                page: paginationData.currentPage + 1,
                max: paginationData.maxPageSize
            )

            engagementManager.emit(.eventList, request)
        }

        private func buildConversationEvent(from response: AddConversationEventResponse) -> ConversationEvent
        {
            return ConversationEvent(
                conversationId: response.conversationId,
                id: response._id ?? "",
                input: response.input,
                metadata: response.metadata,
                options: response.options?.map({
                    ChipOption(displayText: $0.displayText,input: $0.input, configuration: $0.configuration)
                }),
                sentAt: response.sentAt,
                sentBy: response.sentBy
            )
        }
    }
}
