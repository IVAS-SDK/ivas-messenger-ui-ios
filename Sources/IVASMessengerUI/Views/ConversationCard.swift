import SwiftUI

@available(iOS 15, *)
struct ConversationCard: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    var holder: NavStackHolder

    var body: some View
    {
        VStack(alignment: .leading)
        {
            RecentCardSection(config: config, engagementManager: engagementManager, holder: holder)

            if let title = engagementManager.settings?.newConversationTitle, !title.isEmpty
            {
                Text(title)
                    .font(.headline)
                    .padding(.vertical)
            }
            if let subtitle = engagementManager.settings?.newConversationSubtitle, !subtitle.isEmpty
            {
                Text(subtitle)
                    .fontWeight(.light)
                    .padding(.bottom)
            }
            if let button = engagementManager.settings?.newConversationButton, !button.isEmpty
            {
                Button(button)
                {
                    viewModel.startNewConversation(controller: holder.viewController)
                }
                .buttonStyle(.borderedProminent)
                .tint(engagementManager.settings?.actionColor)
            }
        }
        .onAppear() { viewModel.onAppear() }
        .onDisappear() { viewModel.onDisappear() }
    }

    init(config: Configuration, engagementManager: EngagementManager, holder: NavStackHolder)
    {
        self.config = config
        self.engagementManager = engagementManager
        self.holder = holder

        _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager))
    }
}
