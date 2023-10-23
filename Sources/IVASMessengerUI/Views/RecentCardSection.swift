import SwiftUI

@available(iOS 15, *)
struct RecentCardSection: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    var holder: NavStackHolder

    var body: some View
    {
        VStack(alignment: .leading)
        {
            if let conversation = viewModel.recentConversation
            {
                Text(
                    "ivas.landingView.recentConversationTitle",
                    bundle: engagementManager.localizationBundle
                )
                    .font(.headline)

                ConversationCell(
                    config: config,
                    engagementManager: engagementManager,
                    conversation: conversation,
                    holder: holder
                )
                    .buttonStyle(.borderless)

                Divider()

                Button(String(
                    localized: "ivas.landingView.allConversationsButton",
                    bundle: engagementManager.localizationBundle
                ))
                {
                    viewModel.showConversationList(controller: holder.viewController)
                }
                .buttonStyle(.borderless)
                .tint(engagementManager.settings?.actionColor)

                Divider()
            }
        }
        .onFirstAppear() { viewModel.onFirstAppear() }
        .onAppear() { viewModel.onAppear() }
        .onDisappear() { viewModel.onDisappear() }
        .onChange(of: engagementManager.isAuthenticated) { viewModel.onAuthChange($0) }
        .onChange(of: engagementManager.currentScreen) { viewModel.onScreenChange($0) }
    }

    init(config: Configuration, engagementManager: EngagementManager, holder: NavStackHolder)
    {
        self.config = config
        self.engagementManager = engagementManager
        self.holder = holder

        _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager))
    }
}
