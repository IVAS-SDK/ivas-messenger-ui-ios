import SwiftUI

@available(iOS 15, *)
struct ConversationEventView: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    
    let event: ConversationEvent
    let showLoadingIndicator: Bool
    let isLast: Bool

    var body: some View
    {
        VStack
        {
            if showLoadingIndicator
            {
                LoadingView()
            }
            
            if engagementManager.userId == event.sentBy?.userId
            {
                UserEventView(engagementManager: engagementManager, event: event)
                    .id(event.id)
                    .padding()
            }
            else
            {
                NonUserEventView(config: config, engagementManager: engagementManager, event: event, isLast: isLast)
                    .id(event.id)
                    .padding()
            }

            if let formJson = event.metadata?["outputs"]?["useForm"], isLast
            {
                FormView(
                    config: config,
                    engagementManager: engagementManager,
                    form: formJson,
                    conversationId: event.conversationId
                )
                .padding()
            }

            if let options = event.options, isLast, !options.isEmpty
            {
                ChipCollectionView(
                    config: config,
                    engagementManager: engagementManager,
                    options: options,
                    conversationId: event.conversationId
                )
                .padding()
            }
            
            if let _ = event.metadata?["outputs"]?["surveyData"], isLast
            {
                SurveyView(config: config, engagementManager: engagementManager, event: event, isLast: isLast)
            }
        }
    }
}
