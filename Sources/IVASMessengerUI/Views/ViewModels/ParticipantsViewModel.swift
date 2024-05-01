import Foundation

@available(iOS 15, *)
extension ParticipantsView
{
    @MainActor class ViewModel: ObservableObject
    {
        @Published var participantsData = [Participant]()

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
        }

        func getSingleParticipantName() -> String
        {
            return participantsData.first?.name ?? ""
        }

        func getSingleParticipantType() -> String
        {
            return participantsData.first?.type ?? ""
        }

        func getMultipleParticipantsName() -> String
        {
            return participantsData.compactMap({ $0.name }).joined(separator: ", ")
        }

        // MARK: - Helper Methods

        private func registerEventHandlers()
        {
            guard eventHandlers.isEmpty
            else
            {
                return
            }
            
            eventHandlers.append(engagementManager.registerHandler(.conversationUpdateParticipants)
            { [weak self] (response: UpdateParticipantsResponse) in

                self?.participantsData = self?.filterCurrentUser(data: response.participantsData) ?? []
            })

            eventHandlers.append(engagementManager.registerHandler(.eventList)
            { [weak self] (response: ConversationEventsResponse) in

                self?.participantsData = self?.filterCurrentUser(data: response.conversation.participantsData) ?? []
            })
        }

        private func unregisterEventHandlers()
        {
            eventHandlers.forEach { engagementManager.unregisterHandler(id: $0) }
            eventHandlers = []
        }

        private func filterCurrentUser(data: [String: Participant]) -> [Participant]
        {
            return data.filter
            { [weak self] in

                $0.key != self?.engagementManager.userId

            }.map({ $0.value })
        }
    }
}
